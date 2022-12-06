/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
#import <RakutenWebClientKit/RWCDefines.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Abstract model class whose subclasses automatically inherit the ability to produce deep (one level of depth) copies.
 *
 *  This class is designed to be subclassed for models who must support NSCopying. This class uses the Objective-C runtime to query all
 *  properties of the receiving class up to and excluding properties of RWCAutoCopyableModel. From that property list, any weak properties
 *  are ignored since they are not reliable for equality and can often lead to infinite loops with a child-parent relationship in the
 *  @c RWCAutoCopyableModel::description method. Any remaining properties are used in the @c RWCAutoCopyableModel::description,
 *  @c RWCAutoCopyableModel::hash, and @c RWCAutoCopyableModel::isEqual: methods via key-value-coding.
 *
 *  For copying, the list of properties is further filtered to ignore readonly properties without a backing Ivar synthesized, since setting
 *  such a property would likely result in an exception. The copy is produced using a simple @c -init call, so subclasses which define a
 *  designated initializer should take care to either produce a valid @c -init convenience initializer or override the NSCopying
 *  implementation.
 *
 *  @class RWCAutoCopyableModel RWCAutoCopyableModel.h <RakutenWebClientKit/RWCAutoCopyableModel.h>
 *  @ingroup RWCUtilities
 */
RWC_EXPORT @interface RWCAutoCopyableModel : NSObject <NSCopying>

/**
 *  Acquires a string description of the receiver by enumerating its properties and using key-value-coding to extract associated values.
 *
 *  @return A string description of the receiver
 */
- (NSString *)description;

/**
 *  The hash of the receiver computed by XOR combining the hashes of all property values extracted using key-value coding.
 *
 *  @return A hash for the receiver
 */
- (NSUInteger)hash;

/**
 *  Checks if the given object is equal to the receiver in terms of class and property values extracted using key-value coding.
 *
 *  @param object The object to compare the receiver against
 *
 *  @return YES if the object is the same kind of class as the receiver and has the same property values as the reciever
 */
- (BOOL)isEqual:(nullable id)object;

@end

NS_ASSUME_NONNULL_END

