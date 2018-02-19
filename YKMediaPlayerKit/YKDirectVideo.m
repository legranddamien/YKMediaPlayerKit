//
//  YKDirectVideo.m
//  YKMediaHelper
//
//  Created by Yas Kuraishi on 3/13/14.
//  Copyright (c) 2014 Yas Kuraishi. All rights reserved.
//

#import "YKDirectVideo.h"
#import "YKHelper.h"

CGFloat const kDirectThumbnailLocation = 1.0;

@interface YKDirectVideo()

@property (nonatomic, strong) void(^thumbnailCallback)(UIImage *thumbImage, NSError *error);

@end

@implementation YKDirectVideo

#pragma mark - YKVideo Protocol

- (void)parseWithCompletion:(void(^)(NSError *error))callback
{
    NSAssert(self.contentURL, @"Direct URLs to natively supported formats such as MP4 do not require calling this method.");
}

- (void)thumbImage:(YKQualityOptions)quality completion:(void(^)(UIImage *thumbImage, NSError *error))callback
{
    NSAssert(callback, @"usingBlock cannot be nil");
    
    [self buildPlayerWithQuality:quality];
    _thumbnailCallback = callback;
    [self.videoPlayer.player.currentItem addObserver:self forKeyPath:@"status" options:0 context:nil];
}

- (NSURL *)videoURL:(YKQualityOptions)quality
{
    return self.contentURL;
}

#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    if(object == self.videoPlayer.player.currentItem && [keyPath isEqualToString:@"status"])
    {
        AVPlayerItem *item = (AVPlayerItem *)object;
        if (item.status == AVPlayerItemStatusReadyToPlay) {
            [self.videoPlayer.player.currentItem removeObserver:self forKeyPath:@"status"];
            
            //get the thumbnail
            AVURLAsset *asset = (AVURLAsset *)item.asset;
            AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            CGImageRef thumb = [imageGenerator copyCGImageAtTime:CMTimeMakeWithSeconds(10.0, 1.0)
                                                      actualTime:NULL
                                                           error:NULL];
            
            UIImage *thumbnail = [UIImage imageWithCGImage:thumb];
            CGImageRelease(thumb);
            
            if(_thumbnailCallback) _thumbnailCallback(thumbnail, nil);
        }
        else if (item.status == AVPlayerItemStatusFailed)
        {
            [self.videoPlayer.player.currentItem removeObserver:self forKeyPath:@"status"];
            if(_thumbnailCallback) _thumbnailCallback(nil, item.error);
        }
    }
}

@end
