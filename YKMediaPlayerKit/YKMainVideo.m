//
//  YKMainVideo.m
//  Pods
//
//  Created by Damien Legrand on 05/01/2016.
//
//

#import "YKMainVideo.h"
#import "YKHelper.h"

@interface YKVideoAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic) BOOL reverse;

@end


@interface YKMainVideo () <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) YKVideoAnimator *presentAnimator;
@property (nonatomic, strong) YKVideoAnimator *dismissAnimator;

@end

@implementation YKMainVideo

- (instancetype)initWithContent:(NSURL *)contentURL {
    self = [super init];
    if (self) {
        self.contentURL = contentURL;
    }
    return self;
}

- (NSString *)title
{
    return nil;
}

- (NSURL *)videoURL:(YKQualityOptions)quality
{
    NSAssert(false, @"Override this method !");
    return nil;
}

- (void)thumbImage:(YKQualityOptions)quality completion:(void(^)(UIImage *, NSError *))callback
{
    NSAssert(false, @"Override this method !");
}

- (void)parseWithCompletion:(void (^)(NSError *))callback
{
    NSAssert(false, @"Override this method !");
}

- (BOOL)hasPlayerWithQuality:(YKQualityOptions)quality
{
    return (((YK_IOS8 && self.videoPlayer)
             || (!YK_IOS8 && self.player)) && quality == _currentQuality);
}

- (void)buildPlayerWithQuality:(YKQualityOptions)quality
{
    if([self hasPlayerWithQuality:quality]) return;
    
    if(YK_IOS8)
    {
        AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:[self videoURL:quality]];
        AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:item];
        
        self.videoPlayer = [[YKAVPlayerViewController alloc] init];
        self.videoPlayer.player = player;
    }
    else
    {
        _Pragma("clang diagnostic push")
        _Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"")
        
        self.player = [[MPMoviePlayerViewController alloc] initWithContentURL:[self videoURL:quality]];
        [self.player.moviePlayer setShouldAutoplay:NO];
        [self.player.moviePlayer prepareToPlay];
        
        _Pragma("clang diagnostic pop")
    }
}

_Pragma("clang diagnostic push")
_Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"")
- (MPMoviePlayerViewController *)movieViewController:(YKQualityOptions)quality {
    self.player = [[MPMoviePlayerViewController alloc] initWithContentURL:[self videoURL:quality]];
    [self.player.moviePlayer setShouldAutoplay:NO];
    [self.player.moviePlayer prepareToPlay];
    
    return self.player;
}
_Pragma("clang diagnostic pop")

- (AVPlayerViewController *)playerViewController:(YKQualityOptions)quality
{
    [self buildPlayerWithQuality:quality];
    return self.videoPlayer;
}


- (void)play:(YKQualityOptions)quality {
    [self buildPlayerWithQuality:quality];
    
    if(YK_IOS8)
    {
        [self presentController:self.videoPlayer completion:^{
            [self.videoPlayer.player play];
        }];
    }
    else
    {
        [self presentController:self.player completion:^{
            [self.player.moviePlayer play];
        }];
    }
}

- (void)play:(YKQualityOptions)quality fromSourceController:(UIViewController *)sourceController
{
    [self buildPlayerWithQuality:quality];
    
    if(YK_IOS8)
    {
        [self presentController:self.videoPlayer sourceController:sourceController completion:^{
            [self.videoPlayer.player play];
        }];
    }
    else
    {
        [self presentController:self.player sourceController:sourceController completion:^{
            [self.player.moviePlayer play];
        }];
    }
}

- (YKVideoAnimator *)presentAnimator
{
    if(_presentAnimator) return _presentAnimator;
    _presentAnimator = [YKVideoAnimator new];
    return _presentAnimator;
}

- (YKVideoAnimator *)dismissAnimator
{
    if(_dismissAnimator) return _dismissAnimator;
    _dismissAnimator = [YKVideoAnimator new];
    _dismissAnimator.reverse = YES;
    return _dismissAnimator;
}

- (void)presentController:(UIViewController *)controller completion:(void (^)(void))completion
{
    [self presentController:controller sourceController:[[UIApplication sharedApplication].keyWindow rootViewController] completion:completion];
}

- (void)presentController:(UIViewController *)controller sourceController:(UIViewController *)sourceController completion:(void (^)(void))completion
{
    _Pragma("clang diagnostic push")
    _Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"")
    if(![controller isKindOfClass:[MPMoviePlayerViewController class]])
    {
        controller.transitioningDelegate = self;
        controller.modalPresentationStyle = UIModalPresentationFullScreen;
        [sourceController presentViewController:controller
                                       animated:YES
                                     completion:^{
                                         if(completion) completion();
                                     }];
    }
    else
    {
        [sourceController presentMoviePlayerViewControllerAnimated:(MPMoviePlayerViewController *)controller];
        if(completion) completion();
    }
    
    _Pragma("clang diagnostic pop")
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    return self.presentAnimator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self.dismissAnimator;
}


@end

@implementation YKVideoAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    if(!self.reverse) //presenting
    {
        fromViewController.view.userInteractionEnabled = NO;
        
        CGRect frameTo = toViewController.view.frame;
        frameTo.size = [transitionContext containerView].frame.size;
        frameTo.origin = CGPointZero;
        
        toViewController.view.frame = frameTo;
        
        CGRect frameFrom = fromViewController.view.frame;
        
        frameFrom.origin.y = 0;
        fromViewController.view.frame = frameFrom;
        
        frameFrom.origin.y = frameFrom.size.height;
        [[transitionContext containerView] addSubview:toViewController.view];
        [[transitionContext containerView] addSubview:fromViewController.view];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            fromViewController.view.frame = frameFrom;
            
        } completion:^(BOOL finished) {
            
            [transitionContext completeTransition:YES];
            
        }];

    }
    else //dismiss
    {
        toViewController.view.userInteractionEnabled = YES;
        
        CGRect frameTo = toViewController.view.frame;
        frameTo.size = [transitionContext containerView].frame.size;
        frameTo.origin = CGPointMake(0, frameTo.size.height);
        
        toViewController.view.frame = frameTo;
        
        CGRect frameFrom = fromViewController.view.frame;
        frameFrom.origin = CGPointZero;
        fromViewController.view.frame = frameFrom;
        
        frameTo.origin.y = 0;
        
        [[transitionContext containerView] addSubview:fromViewController.view];
        [[transitionContext containerView] addSubview:toViewController.view];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            toViewController.view.frame = frameTo;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
}

@end
