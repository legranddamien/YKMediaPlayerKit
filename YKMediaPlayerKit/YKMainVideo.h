//
//  YKMainVideo.h
//  Pods
//
//  Created by Damien Legrand on 05/01/2016.
//
//

#import <Foundation/Foundation.h>
#import "YKVideo.h"
#import "YKAVPlayerViewController.h"

@interface YKMainVideo : NSObject <YKVideo>

@property (nonatomic, strong) NSURL *contentURL;

@property (nonatomic, strong) YKAVPlayerViewController *videoPlayer;
@property (nonatomic) YKQualityOptions currentQuality;

- (void)buildPlayerWithQuality:(YKQualityOptions)quality;

- (void)presentController:(UIViewController *)controller completion:(void (^)(void))completion;
- (void)presentController:(UIViewController *)controller sourceController:(UIViewController *)sourceController completion:(void (^)(void))completion;

@end
