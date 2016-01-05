//
//  YKMainVideo.m
//  Pods
//
//  Created by Damien Legrand on 05/01/2016.
//
//

#import "YKMainVideo.h"
#import "YKHelper.h"

@implementation YKMainVideo

- (instancetype)initWithContent:(NSURL *)contentURL {
    self = [super init];
    if (self) {
        self.contentURL = contentURL;
    }
    return self;
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
        
        self.videoPlayer = [[AVPlayerViewController alloc] init];
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
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self.videoPlayer
                                                                                     animated:YES
                                                                                   completion:^{
                                                                                       [self.videoPlayer.player play];
                                                                                   }];
    }
    else
    {
        _Pragma("clang diagnostic push")
        _Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"")
        [[UIApplication sharedApplication].keyWindow.rootViewController presentMoviePlayerViewControllerAnimated:self.player];
        [self.player.moviePlayer play];
        _Pragma("clang diagnostic pop")
    }
}

@end
