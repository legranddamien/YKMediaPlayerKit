//
//  YKDirectVideo.m
//  YKMediaHelper
//
//  Created by Yas Kuraishi on 7/20/14.
//  Copyright (c) 2014 Yas Kuraishi. All rights reserved.
//

#import "YKUnKnownVideo.h"
#import "YKHelper.h"
#import "YKWebViewController.h"

@implementation YKUnKnownVideo

#pragma mark - YKVideo Protocol

- (void)parseWithCompletion:(void(^)(NSError *error))callback
{
    NSAssert(self.contentURL, @"Invalid contentURL");
}

- (void)thumbImage:(YKQualityOptions)quality completion:(void(^)(UIImage *thumbImage, NSError *error))callback
{
    NSAssert(callback, @"completion block cannot be nil");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (callback) callback(nil, nil);
    });
}

- (NSURL *)videoURL:(YKQualityOptions)quality
{
    return self.contentURL;
}

#pragma warning Move to Parent class

- (void)play:(YKQualityOptions)quality
{
    [self presentController:[YKWebViewController modalWithURL:[self videoURL:YKQualityHigh]] completion:nil];
}

- (void)play:(YKQualityOptions)quality fromSourceController:(UIViewController *)sourceController
{
    [self presentController:[YKWebViewController modalWithURL:[self videoURL:YKQualityHigh]] sourceController:sourceController completion:nil];
}

@end
