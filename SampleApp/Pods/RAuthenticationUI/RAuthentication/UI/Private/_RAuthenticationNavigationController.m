/*
 * © Rakuten, Inc.
 */
#import "_RAuthenticationNavigationController.h"
#import "_RAuthenticationUIValues.h"
#import "_RAuthenticationUIHelpers.h"

@interface _RAuthenticationNavigationBar()
@property (nonatomic) UIProgressView *progressView;
@end

@implementation _RAuthenticationNavigationBar
- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        _progressView = [UIProgressView.alloc initWithProgressViewStyle:UIProgressViewStyleBar];
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        self.barTintColor = _RAuthenticationUIValues.NAVIGATION_BAR_BACKGROUND_COLOR;
        self.tintColor    = _RAuthenticationUIValues.NAVIGATION_BAR_LINK_COLOR;
        [self setTitleTextAttributes:@{NSForegroundColorAttributeName: _RAuthenticationUIValues.NAVIGATION_BAR_TITLE_COLOR}];
        [self addSubview:_progressView];
    }
    return self;
}

static void *progressObservingContext = &progressObservingContext;
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == progressObservingContext)
    {
        typeof(self) __weak weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            typeof(weakSelf) __strong strongSelf = weakSelf;
            UIProgressView *progressView = strongSelf.progressView;
            NSProgress *progress = strongSelf.observedProgress;
            float fractionCompleted = (float)progress.fractionCompleted;
            if (progress == object)
            {
                [progressView setProgress:fractionCompleted animated:YES];
            }
        });
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)attachProgress:(NSProgress *)progress
{
    [_observedProgress removeObserver:self forKeyPath:@"fractionCompleted" context:progressObservingContext];
    [progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:progressObservingContext];
    _observedProgress = progress;
}

- (void)dealloc
{
    [self attachProgress:nil];
}

- (void)setObservedProgress:(NSProgress *)observedProgress
{
    if (observedProgress != _observedProgress)
    {
        [self attachProgress:observedProgress];
        
        // Animate to observedProgress, or reset immediately if observedProgress is nil.
        [_progressView setProgress:(float)observedProgress.fractionCompleted animated:(BOOL)observedProgress];
    }
}
@end

@interface _RAuthenticationNavigationController ()<UIViewControllerTransitioningDelegate,
UIViewControllerAnimatedTransitioning>
@end

@implementation _RAuthenticationNavigationController

#pragma mark UINavigationController
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    if ((self = [super initWithNavigationBarClass:_RAuthenticationNavigationBar.class toolbarClass:nil]))
    {
        if (rootViewController)
        {
            [self pushViewController:rootViewController animated:NO];
        }
    }
    return self;
}

#pragma mark UIViewController
- (instancetype)initWithNibName:(NSString *__unused)nibNameOrNil bundle:(NSBundle *__unused)nibBundleOrNil
{
    if ((self = [super initWithNibName:nil bundle:nil]))
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            self.transitioningDelegate  = self;
        }
        self.modalPresentationCapturesStatusBarAppearance = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

#ifdef __IPHONE_13_0
    if (@available(iOS 13.0, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
#endif
}

#pragma mark NSObject
- (instancetype)init
{
    return ((self = [super initWithNavigationBarClass:_RAuthenticationNavigationBar.class toolbarClass:nil]));
}

#pragma mark <UIViewControllerTransitioningDelegate>
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController * __unused)presented presentingController:(UIViewController * __unused)presenting sourceController:(UIViewController * __unused)source
{
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController * __unused)dismissed
{
    return self;
}

#pragma mark <UIViewControllerAnimatedTransitioning>
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning> __unused)transitionContext
{
    return CATransaction.animationDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    // Use the view's window as the parent, not the view
    UIView *window = transitionContext.containerView.window;
    UIView *view = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view;
    view.frame = (CGRect){.size = window.bounds.size };
    view.alpha = 0;
    
    [window addSubview:view];
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        view.alpha = 1;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
    }];
}
@end
