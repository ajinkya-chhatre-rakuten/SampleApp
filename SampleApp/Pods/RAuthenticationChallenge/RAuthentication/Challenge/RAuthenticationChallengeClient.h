/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationChallenge/RAuthenticationChallengeDefines.h>
@class RAuthenticationSolvedChallenge;


NS_ASSUME_NONNULL_BEGIN

/**
 * Error domain for errors passed to the completion block of
 * RAuthenticationChallengeClient::requestChallengeWithCompletion:.
 * when a error occurs during challenge request.
 *
 * @ingroup ChallengeConstants
 */
RAUTH_EXPORT NSString * const RAuthenticationChallengeClientErrorDomain;

/**
 * Error codes for errors passed to the completion block of
 * RAuthenticationChallengeClient::requestChallengeWithCompletion:,
 * when a error occurs during challenge request.
 *
 * @enum RAuthenticationChallengeClientErrorCode
 * @ingroup ChallengeConstants
 */
typedef NS_ENUM(NSInteger, RAuthenticationChallengeClientErrorCode)
{
    /**
     *  Error returned when the client received a unsupported challenge type.
     */
    RAuthenticationChallengeClientErrorCodeUnsupportedChallengeType = 1,
    
    /**
     *  Error returned when proof of work challenge solution timeout.
     */
    RAuthenticationChallengeClientErrorCodeProofOfWorkTimeout,
    
    /**
     *  Error returned when the client received a invalid response from backend.
     */
    RAuthenticationChallengeClientErrorCodeInvalidResponse,
};

/**
 * Client for challenger.
 *
 * @class RAuthenticationChallengeClient RAuthenticationChallengeClient.h <RAuthentication/RAuthenticationChallengeClient.h>
 * @ingroup RAuthenticationChallengeClient
 */
RAUTH_EXPORT @interface RAuthenticationChallengeClient : NSObject

/**
 * Designated initializer.
 *
 * @param baseURL Base URL.
 * @param pageId  PageId.
 *
 * @return An initialized instance of the receiver
 */
- (instancetype)initWithBaseURL:(NSURL *)baseURL pageId:(NSString *)pageId NS_DESIGNATED_INITIALIZER;

/**
 * Request a @ref RAuthenticationSolvedChallenge "solved challenge", only proof of work challenge will have a non-empty result value be set.
 *
 * @param completion Block to be called upon completion.
 */
- (NSOperation *)requestChallengeWithCompletion:(void(^)(RAuthenticationSolvedChallenge * _Nullable solvedChallenge, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
