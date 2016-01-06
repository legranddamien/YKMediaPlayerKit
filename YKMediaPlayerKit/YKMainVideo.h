//
//  YKMainVideo.h
//  Pods
//
//  Created by Damien Legrand on 05/01/2016.
//
//

#import <Foundation/Foundation.h>
#import "YKVideo.h"

@interface YKMainVideo : NSObject <YKVideo>

@property (nonatomic, strong) NSURL *contentURL;

_Pragma("clang diagnostic push")
_Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"")
@property (nonatomic, strong) MPMoviePlayerViewController *player;
_Pragma("clang diagnostic pop")

@property (nonatomic, strong) AVPlayerViewController *videoPlayer;
@property (nonatomic) YKQualityOptions currentQuality;

- (void)buildPlayerWithQuality:(YKQualityOptions)quality;

- (void)presentController:(UIViewController *)controller completion:(void (^)(void))completion;
- (void)presentController:(UIViewController *)controller sourceController:(UIViewController *)sourceController completion:(void (^)(void))completion;

@end