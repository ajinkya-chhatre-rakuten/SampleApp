/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationCore.h>
#import "_RAuthenticationHelpers.h"
#import "_RAuthenticationTracking.h"
#include <Security/SecRandom.h>

#define complete(res, e_) do { \
    NSError *e = e_; \
    if (e) _RAuthenticationLog(@"☠️ Failed with error: %@ (reason: %@)!", e.localizedDescription, e.localizedFailureReason); \
    if (error) *error = e; \
    return res; \
} while(0)

static NSString *const kBundleIdentifierOfLastApplicationKey = @"labi";
static NSString *const kDisplayNameOfLastApplicationKey      = @"ladn";
static NSString *const kNameOfTheAuthenticatorClassUsed      = @"auth";

NS_INLINE NSString *tokenServiceForService(NSString *service)
{
    return [NSString stringWithFormat:@"%@.token", service];
}

NS_INLINE NSString *profileServiceForService(NSString *service)
{
    return [NSString stringWithFormat:@"%@.profile", service];
}

NS_INLINE NSString *trackingIdentifierServiceForService(NSString *service)
{
    return [NSString stringWithFormat:@"%@.trackingIdentifier", service];
}

NS_INLINE NSError *errorWithFailedParameterConstraint(NSString *failedConstraint)
{
    NSString *reason = [NSString stringWithFormat:@"Failed pre-flight validation constraint: %@", failedConstraint];
    return [NSError errorWithDomain:RWCAppEngineResponseParserErrorDomain
                               code:RWCAppEngineResponseParserErrorInvalidParameter
                           userInfo:@{NSLocalizedDescriptionKey: @"invalid_request",
                                      NSLocalizedFailureReasonErrorKey: reason}];
}

@implementation RAuthenticationAccount

+(instancetype)accountWithKeychainItem:(NSDictionary *)item
                                 error:(out NSError **)error
{
    if (!item) return nil;

    // Gather what we can from the item
    NSString *serviceIdentifier    = item[(__bridge id)kSecAttrService];
    NSString *name                 = item[(__bridge id)kSecAttrAccount];
    NSDate   *creationDate         = item[(__bridge id)kSecAttrCreationDate];
    NSDate   *lastModificationDate = item[(__bridge id)kSecAttrModificationDate];
    NSString *accessGroup          = _RAuthenticationAccessGroupHelper.shouldUseAccessGroups
                                     ? item[(__bridge id)kSecAttrAccessGroup]
                                     : nil;
    NSData   *passwordData         = item[(__bridge id)kSecValueData];
    NSData   *genericData          = item[(__bridge id)kSecAttrGeneric];

    /*
     * Build the password.
     */
    NSString *password = nil;
    if (passwordData.length)
    {
        password = [NSString.alloc initWithData:passwordData encoding:NSUTF8StringEncoding];
        if (!password) complete(nil, [NSError errorWithDomain:NSOSStatusErrorDomain code:errSecDecode userInfo:nil]);

        if (!password.length) { password = nil; }
    }

    /*
     * Build the account's persistence information object from the keychain
     * item's metadata and the data saved in its 'generic' attribute.
     *
     * Also get the name of the authenticator class from the same location.
     */
    NSString *nameOfAuthenticatorClass = nil;
    RAuthenticationAccountPersistenceInformation *persistenceInformation = RAuthenticationAccountPersistenceInformation.new;

    NSError *localError;
    persistenceInformation.accessGroup = [_RAuthenticationAccessGroupHelper canonicalAccessGroupWithFullyQualifiedAccessGroup:accessGroup error:&localError];
    if (localError) complete(nil, localError);

    persistenceInformation.creationDate         = creationDate ?: lastModificationDate;
    persistenceInformation.lastModificationDate = lastModificationDate;
    if (genericData)
    {
        @try
        {
            NSKeyedUnarchiver *unarchiver = [NSKeyedUnarchiver.alloc initForReadingWithData:genericData];
            unarchiver.requiresSecureCoding = YES;
            persistenceInformation.bundleIdentifierOfLastApplication = [unarchiver decodeObjectOfClass:NSString.class forKey:kBundleIdentifierOfLastApplicationKey];
            persistenceInformation.displayNameOfLastApplication      = [unarchiver decodeObjectOfClass:NSString.class forKey:kDisplayNameOfLastApplicationKey];
            nameOfAuthenticatorClass                                 = [unarchiver decodeObjectOfClass:NSString.class forKey:kNameOfTheAuthenticatorClassUsed];
            [unarchiver finishDecoding];
        }
        @catch (NSException *exception)
        {
            complete(nil, [NSError errorWithDomain:NSOSStatusErrorDomain code:errSecDecode userInfo:nil]);
        }
    }

    /*
     * Sanity check: an account must have an owner, a service, an authenticator class and a creation data.
     */
    if (!name.length || !serviceIdentifier.length || !nameOfAuthenticatorClass.length || !creationDate)
    {
        complete(nil, [NSError errorWithDomain:NSOSStatusErrorDomain code:errSecDecode userInfo:nil]);
    }

    /*
     * Try to load the authenticator class
     */
    Class authenticatorClass = NSClassFromString(nameOfAuthenticatorClass);

    /*
     * Next, try to find the owner's user information.
     */
    CFTypeRef result;
    OSStatus  status;

    NSMutableDictionary *query = NSMutableDictionary.new;
    query[(__bridge id)kSecClass]       = (__bridge id)kSecClassGenericPassword;
    query[(__bridge id)kSecAttrAccount] = name;
    query[(__bridge id)kSecAttrService] = profileServiceForService(serviceIdentifier);
    query[(__bridge id)kSecReturnData]  = @YES;
    if (accessGroup)
    {
        query[(__bridge id)kSecAttrAccessGroup] = accessGroup;
    }

    RAuthenticationAccountUserInformation *userInformation = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status == errSecSuccess)
    {
        @try
        {
            NSKeyedUnarchiver *unarchiver = [NSKeyedUnarchiver.alloc initForReadingWithData:(id)CFBridgingRelease(result)];
            unarchiver.requiresSecureCoding = YES;
            userInformation = [unarchiver decodeObjectOfClass:RAuthenticationAccountUserInformation.class forKey:NSKeyedArchiveRootObjectKey];
            [unarchiver finishDecoding];
        }
        @catch (NSException *exception)
        {
            complete(nil, [NSError errorWithDomain:NSOSStatusErrorDomain code:errSecDecode userInfo:nil]);
        }
    }
    else if (status != errSecItemNotFound) complete(nil, [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil]);

    /*
     * Next, try to find the owner's encrypted easy id
     */
    query[(__bridge id)kSecAttrService] = trackingIdentifierServiceForService(serviceIdentifier);
    NSString *trackingIdentifier = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status == errSecSuccess)
    {
        trackingIdentifier = [NSString.alloc initWithData:(id)CFBridgingRelease(result) encoding:NSUTF8StringEncoding];
    }
    else if (status != errSecItemNotFound) complete(nil, [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil]);

    /*
     * Finally, try to find an access token. Right now we keep the tokens in
     * each app's own access group, but in the future we should store them
     * encrypted with an app-specific key in the shared access group.
     */
    accessGroup = [_RAuthenticationAccessGroupHelper fullyQualifiedPrivateAccessGroupWithError:&localError];
    if (localError) complete(nil, localError);

    query[(__bridge id)kSecAttrService] = tokenServiceForService(serviceIdentifier);
    if (accessGroup)
    {
        query[(__bridge id)kSecAttrAccessGroup] = accessGroup;
    }

    RAuthenticationToken *token = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status == errSecSuccess)
    {
        @try
        {
            NSKeyedUnarchiver *unarchiver = [NSKeyedUnarchiver.alloc initForReadingWithData:(id)CFBridgingRelease(result)];
            unarchiver.requiresSecureCoding = YES;
            token = [unarchiver decodeObjectOfClass:RAuthenticationToken.class forKey:NSKeyedArchiveRootObjectKey];
            [unarchiver finishDecoding];
        }
        @catch (NSException *exception)
        {
            complete(nil, [NSError errorWithDomain:NSOSStatusErrorDomain code:errSecDecode userInfo:nil]);
        }
    }
    else if (status != errSecItemNotFound)
    {
        complete(nil, [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil]);
    }

    RAuthenticationAccount *account = RAuthenticationAccount.new;

    account.persistenceInformation           = persistenceInformation;
    account.userInformation                  = userInformation;
    account.token                            = token;
    account.serviceIdentifier                = serviceIdentifier;
    account.name                             = name;
    account.password                         = password;
    account.authenticatorClass               = authenticatorClass;
    account.trackingIdentifier               = trackingIdentifier;

    _RAuthenticationLog(@"✅ Retrieved account \"%@\" for service \"%@\".", name, serviceIdentifier);

    if (!token.isValid && !token.refreshToken.length)
    {
        [account invalidateTokenWithError:0];
        _RAuthenticationLog(@"The account is not associated with a valid token.");
    }

    complete(account, nil);
}

- (BOOL)persistWithError:(out NSError **)error
{
    _RAuthenticationLog(@"Persisting account \"%@\" for service \"%@\" into the keychain…", self.name, self.serviceIdentifier);

    /*
     * Do some sanity check. In order to be saved, accounts must have a name and
     * a service identifier. Also, their shouldAgreeToTermsAndConditions property
     * must not be set.
     */
    if (!_name.length)
        complete(NO, (errorWithFailedParameterConstraint([NSString stringWithFormat:@"\"name\" must be non-empty: %@", self.description])));
    if (!_serviceIdentifier.length)
        complete(NO, (errorWithFailedParameterConstraint([NSString stringWithFormat:@"\"serviceIdentifier\" must be non-empty: %@", self.description])));
    if (_userInformation.shouldAgreeToTermsAndConditions)
        complete(NO, (errorWithFailedParameterConstraint([NSString stringWithFormat:@"\"userInformation.shouldAgreeToTermsAndConditions\" is set, so this account cannot be saved yet: %@", self.description])));

    /*
     * Get the persistence information member, or create a new one
     */
    RAuthenticationAccountPersistenceInformation *persistenceInformation = _persistenceInformation ?: RAuthenticationAccountPersistenceInformation.new;
    persistenceInformation.lastModificationDate              = NSDate.new;
    persistenceInformation.creationDate                      = persistenceInformation.creationDate ?: persistenceInformation.lastModificationDate;
    persistenceInformation.bundleIdentifierOfLastApplication = NSBundle.mainBundle.bundleIdentifier;
    persistenceInformation.displayNameOfLastApplication      = _RAuthenticationApplicationName();

    /*
     * If no access group was set, use the private one.
     */
    if (!_RAuthenticationAccessGroupHelper.shouldUseAccessGroups)
    {
        persistenceInformation.accessGroup = nil;
    }
    else if (!persistenceInformation.accessGroup)
    {
        persistenceInformation.accessGroup = NSBundle.mainBundle.bundleIdentifier;
    }

    NSError *accessGroupError = nil;
    NSString *accessGroup = [_RAuthenticationAccessGroupHelper fullyQualifiedAccessGroupWithCanonicalAccessGroup:persistenceInformation.accessGroup error:&accessGroupError];
    if (accessGroupError) complete(NO, accessGroupError);

    /*
     * Persist the account
     */
    OSStatus status;

    NSString        *password     = self.password ?: @"";
    NSData          *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData   *genericData  = NSMutableData.new;
    NSKeyedArchiver *archiver     = [NSKeyedArchiver.alloc initForWritingWithMutableData:genericData];
    [archiver encodeObject:persistenceInformation.bundleIdentifierOfLastApplication forKey:kBundleIdentifierOfLastApplicationKey];
    [archiver encodeObject:persistenceInformation.displayNameOfLastApplication      forKey:kDisplayNameOfLastApplicationKey];
    NSString *authenticatorClassName = nil;
    if (_authenticatorClass)
    {
        authenticatorClassName = NSStringFromClass((Class)_authenticatorClass);
    }
    [archiver encodeObject:authenticatorClassName forKey:kNameOfTheAuthenticatorClassUsed];
    [archiver finishEncoding];

    NSMutableDictionary *query = NSMutableDictionary.new;
    query[(__bridge id)kSecClass]       = (__bridge id)kSecClassGenericPassword;
    query[(__bridge id)kSecAttrAccount] = _name;
    query[(__bridge id)kSecAttrService] = _serviceIdentifier;
    if (accessGroup)
    {
        query[(__bridge id)kSecAttrAccessGroup] = accessGroup;
    }

    NSMutableDictionary *update = NSMutableDictionary.new;
    update[(__bridge id)kSecAttrAccessible]       = (__bridge id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly;
    update[(__bridge id)kSecAttrCreationDate]     = persistenceInformation.creationDate;
    update[(__bridge id)kSecAttrModificationDate] = persistenceInformation.lastModificationDate;
    update[(__bridge id)kSecAttrGeneric]          = genericData;
    update[(__bridge id)kSecValueData]            = passwordData;

    status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)update);
    if (status == errSecItemNotFound)
    {
        _RAuthenticationLog(@"This is a new account.");

        /*
         * Item not found! Merge the dictionaries and add a new item
         * (also set the creation date)
         */
        [query addEntriesFromDictionary:update];
        status = SecItemAdd((__bridge CFDictionaryRef)query, 0);
    }

    if (status != errSecSuccess) complete(NO, [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil]);

    /*
     * Next, try to persist the user information
     */
    if (self.userInformation)
    {
        NSData *userInformationData = [NSKeyedArchiver archivedDataWithRootObject:(id)self.userInformation];

        query = NSMutableDictionary.new;
        query[(__bridge id)kSecClass]       = (__bridge id)kSecClassGenericPassword;
        query[(__bridge id)kSecAttrAccount] = _name;
        query[(__bridge id)kSecAttrService] = profileServiceForService(_serviceIdentifier);
        if (accessGroup)
        {
            query[(__bridge id)kSecAttrAccessGroup] = accessGroup;
        }

        update = NSMutableDictionary.new;
        update[(__bridge id)kSecAttrAccessible]       = (__bridge id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly;
        update[(__bridge id)kSecAttrCreationDate]     = persistenceInformation.creationDate;
        update[(__bridge id)kSecAttrModificationDate] = persistenceInformation.lastModificationDate;
        update[(__bridge id)kSecValueData]            = userInformationData;

        status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)update);
        if (status == errSecItemNotFound)
        {
            [query addEntriesFromDictionary:update];
            status = SecItemAdd((__bridge CFDictionaryRef)query, 0);
        }
        if (status != errSecSuccess) complete(NO, [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil]);
    }

    /*
     * Next, try to persist the encrypted user id
     */
    if (self.trackingIdentifier)
    {
        query = NSMutableDictionary.new;
        query[(__bridge id)kSecClass]       = (__bridge id)kSecClassGenericPassword;
        query[(__bridge id)kSecAttrAccount] = _name;
        query[(__bridge id)kSecAttrService] = trackingIdentifierServiceForService(_serviceIdentifier);
        if (accessGroup)
        {
            query[(__bridge id)kSecAttrAccessGroup] = accessGroup;
        }

        update = NSMutableDictionary.new;
        update[(__bridge id)kSecAttrAccessible]       = (__bridge id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly;
        update[(__bridge id)kSecAttrCreationDate]     = persistenceInformation.creationDate;
        update[(__bridge id)kSecAttrModificationDate] = persistenceInformation.lastModificationDate;
        update[(__bridge id)kSecValueData]            = [self.trackingIdentifier dataUsingEncoding:NSUTF8StringEncoding];

        status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)update);
        if (status == errSecItemNotFound)
        {
            [query addEntriesFromDictionary:update];
            status = SecItemAdd((__bridge CFDictionaryRef)query, 0);
        }
        if (status != errSecSuccess) complete(NO, [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil]);
    }

    /*
     * Finally, try to persist the token for the private access group.
     * We should persist them in encrypted form in the shared access group, later, so
     * that apps can truly delete accounts and log the user out of every app.
     */
    accessGroup = [_RAuthenticationAccessGroupHelper fullyQualifiedPrivateAccessGroupWithError:&accessGroupError];
    if (accessGroupError) complete(NO, accessGroupError);

    if (self.token)
    {
        NSData *tokenData = [NSKeyedArchiver archivedDataWithRootObject:(id)self.token];

        query = NSMutableDictionary.new;
        query[(__bridge id)kSecClass]       = (__bridge id)kSecClassGenericPassword;
        query[(__bridge id)kSecAttrAccount] = _name;
        query[(__bridge id)kSecAttrService] = tokenServiceForService(_serviceIdentifier);
        if (accessGroup.length)
        {
            query[(__bridge id)kSecAttrAccessGroup] = accessGroup;
        }

        update = NSMutableDictionary.new;
        update[(__bridge id)kSecAttrAccessible]       = (__bridge id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly;
        update[(__bridge id)kSecAttrCreationDate]     = persistenceInformation.creationDate;
        update[(__bridge id)kSecAttrModificationDate] = persistenceInformation.lastModificationDate;
        update[(__bridge id)kSecValueData]            = tokenData;
        
        status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)update);
        if (status == errSecItemNotFound)
        {
            [query addEntriesFromDictionary:update];
            status = SecItemAdd((__bridge CFDictionaryRef)query, 0);
        }
        if (status != errSecSuccess) complete(NO, [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil]);
    }
        
    // All good!
    _RAuthenticationLog(@"✅ Persisted successfully!");
    _persistenceInformation = persistenceInformation;
    complete(YES, nil);
}

- (BOOL)unpersistWithError:(out NSError **)error
{
    return [self.class unpersistWithName:(id)_name
                                 service:(id)_serviceIdentifier
                             accessGroup:(id)_persistenceInformation.accessGroup
                                   error:error];
}

+ (BOOL)unpersistWithName:(NSString *)name
                  service:(NSString *)service
              accessGroup:(nullable NSString *)accessGroup_
                    error:(out NSError **)error
{
    _RAuthenticationLog(@"Unpersisting account \"%@\" for service \"%@\"…", name, service);

    if (service.length && name.length)
    {
        NSError *accessGroupError = nil;
        NSString *accessGroup = [_RAuthenticationAccessGroupHelper fullyQualifiedAccessGroupWithCanonicalAccessGroup:accessGroup_ error:&accessGroupError];
        if (accessGroupError) complete(NO, accessGroupError);

        NSMutableDictionary *query = NSMutableDictionary.new;
        query[(__bridge id)kSecClass]       = (__bridge id)kSecClassGenericPassword;
        query[(__bridge id)kSecAttrAccount] = name;
        if (accessGroup)
        {
            query[(__bridge id)kSecAttrAccessGroup] = accessGroup;
        }

        /*
         * Delete the account itself.
         */
        query[(__bridge id)kSecAttrService] = service;
        OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
        if (status != errSecSuccess && status != errSecItemNotFound)
            complete(NO, [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil]);

        /*
         * Delete user information
         */
        query[(__bridge id)kSecAttrService] = profileServiceForService(service);
        status = SecItemDelete((__bridge CFDictionaryRef)query);
        if (status != errSecSuccess && status != errSecItemNotFound)
            complete(NO, [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil]);

        /*
         * Delete any token
         */
        accessGroup = [_RAuthenticationAccessGroupHelper fullyQualifiedPrivateAccessGroupWithError:&accessGroupError];
        if (accessGroupError)
            complete(NO, accessGroupError);

        query[(__bridge id)kSecAttrService] = tokenServiceForService(service);
        if (accessGroup)
        {
            query[(__bridge id)kSecAttrAccessGroup] = accessGroup;
        }
        status = SecItemDelete((__bridge CFDictionaryRef)query);
        if (status != errSecSuccess && status != errSecItemNotFound)
            complete(NO, [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil]);
    }

    _RAuthenticationLog(@"✅ Unpersisted successfully!");
    complete(YES, nil);
}

- (NSOperation *)logoutWithSettings:(RAuthenticationSettings *)settings
                            options:(RAuthenticationLogoutOptions)options
                         completion:(void (^)(NSError *))completion
{
    NSParameterAssert(settings);
    NSParameterAssert(completion);
    NSAssert([_authenticatorClass isSubclassOfClass:RAuthenticator.class], @"Invalid authenticator class");

    _RAuthenticationLog(@"Logging out account \"%@\" for service \"%@\"…", self.name, self.serviceIdentifier);

    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    NSError *__block error = nil;
    RAuthenticator *__block authenticator = [_authenticatorClass.alloc initWithSettings:settings];
    NSString *method = _RAuthenticationSelectorString(self, _cmd);
    NSOperation *operation = _RAuthenticationDispatchGroupOperation(group, ^{
        // Log status
        _RAuthenticationLogSuccessOrFailure(method, error);

        // Release our strong reference on the local authenticator
        authenticator = nil;

        // Invoke the completion block
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(error);
        });
    });
    operation.name = method;
    [authenticator.operationQueue addOperation:operation];

    // Copy the token so it can be revoked remotely after it's invalidated locally.
    RAuthenticationToken *token = _token.copy;

    /*
     * Unpersist the account and/or invalidate the token locally, first, depending on
     * the options. Note this needs to happen on the main queue.
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        if (options & RAuthenticationLogoutDeleteAccount)
        {
            [self unpersistWithError:&error];
            if (!error) [_RAuthenticationTracking broadcastGlobalLogoutEventWithAccount:self];
        }
        else
        {
            [self invalidateTokenWithError:&error];
            if (!error) [_RAuthenticationTracking broadcastLocalLogoutEventWithAccount:self];
        }

        /*
         * Revoke the token, if it's valid. Note this happens on the authenticator's
         * background queue.
         */
        if (!error && (options & RAuthenticationLogoutRevokeAccessToken) && token.isValid)
        {
            dispatch_group_enter(group);
            /*
             * We don't fail logout if the token couldn't be revoked on the backend, as it messes up
             * states within the logout workflow. Note this is strictly equivalent to what we were
             * doing before in the logout workflow, giving up on remote revocation if it failed,
             * so there's no behavioral change when using the standard workflows.
             *
             * In the future, we may want to store the tokens pending remote revocation in a special
             * area, and retry remote revocation as many times as it takes for it to succeed.
             */
            [authenticator revokeToken:token completion:^(NSError *__unused error) {
                dispatch_group_leave(group);
            }];
        }

        dispatch_group_leave(group);
    });

    return operation;
}

- (NSOperation *)refreshTokenWithSettings:(RAuthenticationSettings *)settings
                          requestedScopes:(nullable NSSet *)requestedScopes
                               completion:(rauthentication_account_completion_block_t)completion
{
    NSParameterAssert(settings);
    NSParameterAssert(completion);
    NSAssert([_authenticatorClass isSubclassOfClass:RAuthenticator.class], @"Invalid authenticator class");

    // Reuse the same scopes if requestedScopes is nil
    if (!requestedScopes)requestedScopes = _token.scopes;

    NSString *method = _RAuthenticationSelectorString(self, _cmd);
    rauthentication_account_completion_block_t wrappedCompletion = ^(RAuthenticationAccount *account, NSError *error) {
        _RAuthenticationLogSuccessOrFailure(method, error);
        completion(error ? nil : account, error);
    };

    /*
     * REM-14287: Keep a strong reference to the account being refreshed.
     */
    typeof(self) __strong strongSelf = self;
    __block RAuthenticator *authenticator = [_authenticatorClass.alloc initWithSettings:settings];
    return [authenticator refreshToken:(id)_token scopes:requestedScopes completion:^(NSError *error)
    {
        authenticator = nil;

        // Persist the account again if it was previously persisted.
        if (!error && strongSelf.persistenceInformation.creationDate)
        {
            [strongSelf persistWithError:&error];
        }

        wrappedCompletion(strongSelf, error);
    }];
}

- (BOOL)invalidateTokenWithError:(NSError **)error
{
    // Expire the token locally
    self.token.expirationDate = NSDate.distantPast;

    // Delete the token from the keychain
    NSError *localError;
    NSString *accessGroup = [_RAuthenticationAccessGroupHelper fullyQualifiedPrivateAccessGroupWithError:&localError];
    if (localError)
    {
        if (error) { *error = localError; }
        return NO;
    }

    if (_name.length && _serviceIdentifier.length)
    {
        NSMutableDictionary *query = NSMutableDictionary.new;
        query[(__bridge id)kSecClass]       = (__bridge id)kSecClassGenericPassword;
        query[(__bridge id)kSecAttrAccount] = _name;
        query[(__bridge id)kSecAttrService] = tokenServiceForService(_serviceIdentifier);
        if (accessGroup)
        {
            query[(__bridge id)kSecAttrAccessGroup] = accessGroup;
        }
        OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
        if (status != errSecSuccess && status != errSecItemNotFound)
        {
            if (error) { *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil]; }
            return NO;
        }
    }

    return YES;
}

+ (instancetype)loadAccountWithName:(NSString *)name service:(NSString *)service error:(out NSError **)error;
{
    if (error) { *error = nil; }

    if (!name.length || !service.length)
    {
        if (error) { *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:errSecBadReq userInfo:nil]; }
        return nil;
    }

    NSDictionary *query = @{(__bridge id)kSecClass:             (__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrService:       service,
                            (__bridge id)kSecAttrAccount:       name,
                            (__bridge id)kSecReturnData:        @YES,
                            (__bridge id)kSecReturnAttributes:  @YES};

    CFTypeRef result;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status == errSecItemNotFound)
    {
        return nil;
    }

    if (status != errSecSuccess)
    {
        if (error) { *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil]; }
        return nil;
    }

    return [self accountWithKeychainItem:CFBridgingRelease(result) error:error];
}

+ (NSArray *)loadAccountsWithService:(NSString *)service error:(out NSError **)error
{
    if (error) { *error = nil; }

    if (!service.length)
    {
        if (error) { *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:errSecBadReq userInfo:nil]; }
        return nil;
    }

    NSDictionary *query = @{(__bridge id)kSecClass:             (__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrService:       service,
                            (__bridge id)kSecMatchLimit:        (__bridge id)kSecMatchLimitAll,
                            (__bridge id)kSecReturnData:        @YES,
                            (__bridge id)kSecReturnAttributes:  @YES};

    CFTypeRef result;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);

    if (status == errSecItemNotFound)
    {
        return nil;
    }

    if (status != errSecSuccess)
    {
        if (error) { *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil]; }
        return nil;
    }

    NSArray* dataResults = CFBridgingRelease(result);
    NSMutableArray *accounts = [NSMutableArray arrayWithCapacity:dataResults.count];
    for (NSDictionary *item in dataResults)
    {
        // Just skip the invalid ones
        RAuthenticationAccount *account = [self accountWithKeychainItem:item error:0];
        if (account)
        {
            [accounts addObject:account];
        }
    }

    if (!accounts.count)
    {
        return nil;
    }

    NSComparator comparator = ^NSComparisonResult(RAuthenticationAccount *a, RAuthenticationAccount *b) {
        // Sort in descending order
        return -_RAuthenticationMRUAccountComparator(a, b);
    };

    return [accounts sortedArrayWithOptions:NSSortConcurrent usingComparator:comparator];
}

- (BOOL)isEqualToAccount:(RAuthenticationAccount *)other
{
    if (![other isMemberOfClass:self.class] || other.hash != self.hash) { return NO; }
    return
        _RAuthenticationObjectsEqual(_serviceIdentifier,      other.serviceIdentifier)      &&
        _RAuthenticationObjectsEqual(_name,                   other.name)                   &&
        _RAuthenticationObjectsEqual(_password,               other.password)               &&
        _RAuthenticationObjectsEqual(_persistenceInformation, other.persistenceInformation) &&
        _RAuthenticationObjectsEqual(_userInformation,        other.userInformation)        &&
        _RAuthenticationObjectsEqual(_token,                  other.token)                  &&
        _authenticatorClass == other.authenticatorClass;
}

#pragma mark NSObject
- (NSUInteger)hash
{
    NSString *authenticatorClassName = nil;
    if (_authenticatorClass)
    {
        authenticatorClassName = NSStringFromClass((Class __nonnull)_authenticatorClass);
    }

    return authenticatorClassName.hash ^ _serviceIdentifier.hash ^ _name.hash ^ _password.hash ^ _persistenceInformation.hash ^ _userInformation.hash ^ _token.hash ^ _trackingIdentifier.hash;
}

- (BOOL)isEqual:(id)other
{
    if (other == self) { return YES; }
    if (![other isKindOfClass:self.class]) { return NO; }
    return [self isEqualToAccount:(RAuthenticationAccount *)other];
}

- (NSString *)description
{
    return [NSString stringWithFormat:
            @"<%@: %p>"
            @"\n\t     serviceIdentifier=%@"
            @"\n\t                  name=%@"
            @"\n\t              password=%@"
            @"\n\tpersistenceInformation=%@"
            @"\n\t       userInformation=%@"
            @"\n\t                 token=%@"
            @"\n\t    authenticatorClass=%@"
            @"\n\t    trackingIdentifier=%@",
            NSStringFromClass(self.class), self,
            _serviceIdentifier,
            _name,
            _password,
            _persistenceInformation,
            _userInformation,
            _token,
            _authenticatorClass,
            _trackingIdentifier];
}

#pragma mark <NSCopying>
- (instancetype)copyWithZone:(NSZone *)zone
{
    typeof(self) __strong copy = [[self.class allocWithZone:zone] init];
    copy.serviceIdentifier      = self.serviceIdentifier;
    copy.name                   = self.name;
    copy.password               = self.password;
    copy.persistenceInformation = self.persistenceInformation;
    copy.userInformation        = self.userInformation;
    copy.token                  = self.token;
    copy.authenticatorClass     = self.authenticatorClass;
    copy.trackingIdentifier     = self.trackingIdentifier;
    return copy;
}

@end
