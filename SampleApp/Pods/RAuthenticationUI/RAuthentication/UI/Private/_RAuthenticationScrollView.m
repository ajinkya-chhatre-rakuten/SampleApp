/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationUI/RAuthenticationUI.h>
#import "_RAuthenticationScrollView.h"
#import "_RAuthenticationUIHelpers.h"

/*
 * -[UIApplication sendAction:to:from:forEvent:] sends the passed selector to the first responder,
 * if using `nil` as the recipient. We use this to retrieve the first responder in O(1) time.
 */
static UIControl *focusedControl;

@interface UIResponder (_RAuthenticationScrollView) @end

@implementation UIResponder (_RAuthenticationScrollView)
-(void)_rauthenticationSetAsFirstResponder
{
    focusedControl = (id)([self isKindOfClass:UIControl.class] ? self : nil);
}
@end

static UIControl *__nullable focusedControlInView(UIView *__nullable view)
{
    [UIApplication.sharedApplication sendAction:@selector(_rauthenticationSetAsFirstResponder) to:nil from:nil forEvent:nil];
    if (view && ![focusedControl isDescendantOfView:(id)view])
    {
        focusedControl = nil;
    }
    return focusedControl;
}



@implementation _RAuthenticationScrollView
- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect __unused)frame
{
    if ((self = [super initWithFrame:CGRectZero]))
    {
        self.userInteractionEnabled         = YES;
        self.multipleTouchEnabled           = YES;
        self.bounces                        = YES;
        self.clipsToBounds                  = YES;
        self.showsHorizontalScrollIndicator = NO;
        [self enforceNoTouchDelay];
        [self setupKeyboardEnvironment];
    }
    
    return self;
}

#pragma mark React to keyboard obstruction
- (void)setupKeyboardEnvironment
{
    // Defaut value
    _shouldHandleKeyboardVisibilityEvents = YES;
    
    // Start listening to keyboard events
    NSNotificationCenter *notificationCenter = NSNotificationCenter.defaultCenter;
    [notificationCenter addObserver:self selector:@selector(keyboardVisibilityChanged:)
                               name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardVisibilityChanged:)
                               name:UIKeyboardWillHideNotification object:nil];
    
    // Tapping on a non-editable field will hide the keyboard
    UITapGestureRecognizer *tap = [UITapGestureRecognizer.alloc initWithTarget:self action:@selector(endEditing)];
    tap.cancelsTouchesInView = NO;
    tap.delaysTouchesBegan   = NO;
    tap.delaysTouchesEnded   = NO;
    [self addGestureRecognizer:tap];
}

- (void)endEditing
{
    [self endEditing:YES];
}

- (void)keyboardVisibilityChanged:(NSNotification *)notification
{
    if (!_shouldHandleKeyboardVisibilityEvents || !self.window)
    {
        return;
    }
    
    id info = notification.userInfo;
    
    CGRect keyboardRect = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.superview convertRect:keyboardRect fromView:self.window];
    CGRect intersection = CGRectIntersection(keyboardRect, self.frame);
    if (intersection.size.height == 0)
    {
        // No overlap, no need to adjust
        return;
    }
    
    NSNumber *animationDurationValue = info[UIKeyboardAnimationDurationUserInfoKey];
    double animationDuration = animationDurationValue.doubleValue;
    
    NSNumber *animationCurveValue = info[UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationOptions animationOptions = animationCurveValue.unsignedIntegerValue << 16;
    
    CGFloat bottomMargin = self.bounds.size.height - keyboardRect.origin.y;
    
    UIEdgeInsets contentInset = UIEdgeInsetsMake(self.contentInset.top, 0.0, bottomMargin, 0.0);
    UIEdgeInsets scrollIndicatorInsets = UIEdgeInsetsMake(self.scrollIndicatorInsets.top, 0, bottomMargin, 0);
    
    CGPoint contentOffset = self.contentOffset;
    CGFloat viewHeight = self.bounds.size.height;
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification])
    {
        UIControl *controlToScrollTo = focusedControlInView(self);
        if (controlToScrollTo)
        {
            CGRect frame = [controlToScrollTo convertRect:controlToScrollTo.bounds toView:self];
            
            // Fun! (changing contentOffset because scrollRectToVisible doesn't work :/)
            contentOffset.y
            = MIN(contentOffset.y,
                  MAX(0,
                      frame.origin.y - contentInset.top))
            + MAX(0, frame.origin.y + frame.size.height - contentOffset.y - viewHeight + contentInset.bottom);
        }
    }
    // contentOffset shouldn't be greater than the visible area
    contentOffset.y = MIN(contentOffset.y, self.contentSize.height - viewHeight + contentInset.bottom);
    
    typeof(self) __weak weakSelf = self;
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:animationOptions | UIViewAnimationOptionBeginFromCurrentState
                     animations:^
     {
         typeof(weakSelf) __strong strongSelf = weakSelf;
         
         strongSelf.contentInset          = contentInset;
         strongSelf.scrollIndicatorInsets = scrollIndicatorInsets;
         strongSelf.contentOffset         = contentOffset;
         
     } completion:nil];
}

#pragma mark Touch events handling
/*
 * Fixes touch events handing for the controls inside view
 * See http://stackoverflow.com/a/19656611/148374
 */
- (void)enforceNoTouchDelay
{
    self.delaysContentTouches = NO;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    if ([view isKindOfClass:UIControl.class])
    {
        return YES;
    }
    
    return [super touchesShouldCancelInContentView:view];
}
@end
