#import <RakutenEngineClient/RETokenRequestContext.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Concrete conformer of RETokenRequestContext used to contextualize RETokenRequest instancess for Global Ichiba member tokens.
 *
 *  This context is used to provide context to RETokenRequest instances indicating that the resulting tokens have Global Ichiba member
 *  permissions, meaning they can be used for Rakuten App Engine web services which target specific Global Ichiba member information. Note
 *  that this will not work for those web services which require Japan Ichiba member permissions. Furthermore, tokens are marketplace
 *  specific, meaning that tokens generated in one marketplace cannot be used to authenticate requests for a different marketplace.
 *
 *  Unlike majority of the other concrete RETokenRequestContext conformers, this class' RETokenRequestContext::requestURLPath is set to
 *  @c \@"engine/gtoken".
 *
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=675863661
 *
 *  @class REGlobalPasswordTokenRequestContext REGlobalPasswordTokenRequestContext.h <RakutenEngineClient/REGlobalPasswordTokenRequestContext.h>
 *  @ingroup RERequests
 *  @deprecated Global ID support is deprecated and will be removed in the next major version of our SDK (3.0), scheduled to be released in Q1 2017. Applications relying on Global ID are invited to implement and maintain authentication as part of their source code base.
 */
DEPRECATED_MSG_ATTRIBUTE("Global ID support is deprecated and will be removed in the next major version of our SDK (3.0), scheduled to be released in Q1 2017. Applications relying on Global ID are invited to implement and maintain authentication as part of their source code base.")
RWC_EXPORT @interface REGlobalPasswordTokenRequestContext : NSObject <RETokenRequestContext>

/**
 *  Designated initializer which takes the Global Ichiba member's username and password as well as the marketplace in which the tokens
 *  should be generated
 *
 *  @param username              The Global Ichiba member's username
 *  @param password              The Global Ichiba member's password
 *  @param marketplaceIdentifier The identifier of the marketplace in which the tokens should be generated
 *
 *  @return An initialized instance of the receiver
 */
- (instancetype)initWithUsername:(NSString *)username
                        password:(NSString *)password
           marketplaceIdentifier:(NSString *)marketplaceIdentifier NS_DESIGNATED_INITIALIZER;

/**
 *  The username of the Global Ichiba member
 */
@property (copy, nonatomic) NSString *username;

/**
 *  The password of the Global Ichiba member
 */
@property (copy, nonatomic) NSString *password;

/**
 *  The identifier of the marketplace in which the tokens should be created
 *
 *  @note The receiver will generate marketplace specific tokens, so if the resulting tokens are used in a web service which accepts a
 *        marketplace identifier and requires a Global member token, it is important to use the same marketplace identifier in which the
 *        tokens were generated.
 *
 *  Currently supported marketplace identifiers include: @c \@"es" for Spain, @c \@"sg" for Singapore, @c \@"id" for Indonesia, @c \@"my"
 *  for Malaysia, @c \@"gb" for the United Kingdom, and @c \@"tw" for Taiwan.
 */
@property (copy, nonatomic) NSString *marketplaceIdentifier;

/**
 *  Optional identifier used for tracking purposes to identify the method by which Global Ichiba members are logged in
 */
@property (copy, nonatomic, nullable) NSString *loginRoute;

@end

NS_ASSUME_NONNULL_END
