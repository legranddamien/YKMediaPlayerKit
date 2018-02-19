//
//  YKFacebookVideo.m
//  Pods
//
//  Created by Damien Legrand on 05/01/2016.
//
//

#import "YKFacebookVideo.h"
#import "YKHelper.h"
#import "YKWebViewController.h"

#import <FBSDKCoreKit/FBSDKGraphRequest.h>

@interface YKFacebookVideo ()

@property (nonatomic, strong) NSString *thumbHigh;
@property (nonatomic, strong) NSString *thumbMedium;
@property (nonatomic, strong) NSString *thumbLow;

@property (nonatomic, strong) NSString *embed;
@property (nonatomic, strong) NSString *identifier;

@property (nonatomic, strong) NSString *desc;

@property (nonatomic) BOOL parsed;

@end

@implementation YKFacebookVideo

- (NSString *)title
{
    return _desc;
}

- (void)parseWithCompletion:(void(^)(NSError *error))callback
{
    NSAssert(self.contentURL, @"Invalid contentURL");
    
    if(_parsed)
    {
        if(callback) callback(nil);
    }
    
    _parsed = YES;
    
    NSArray *exploded = [self.contentURL.absoluteString componentsSeparatedByString:@"/"];
    NSString *identifier = nil;
    
    BOOL next = NO;
    for (NSString *path in exploded)
    {
        if(next)
        {
            identifier = path;
            break;
        }
        
        if([path isEqualToString:@"video"] || [path isEqualToString:@"videos"])
        {
            next = YES;
        }
    }
    
    _identifier = identifier;
    
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:[NSString stringWithFormat:@"/%@", identifier]
                                  parameters:@{ @"fields": @"thumbnails,embed_html,description",}
                                  HTTPMethod:@"GET"];
    
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        
        if(error)
        {
            if(callback) callback(error);
            return;
        }
        
        self.embed = result[@"embed_html"];
        self.desc = result[@"description"];
        
        NSArray *data = result[@"thumbnails"][@"data"];
        
        if(data.count > 0)
        {
            data = [data sortedArrayUsingComparator:^NSComparisonResult(NSDictionary * obj1, NSDictionary * obj2) {
                
                if([obj1[@"height"] integerValue] > [obj2[@"height"] integerValue]) return NSOrderedAscending;
                if([obj1[@"height"] integerValue] < [obj2[@"height"] integerValue]) return NSOrderedDescending;
                return NSOrderedSame;
            }];
            
            self.thumbHigh = data[0][@"uri"];
            
            if(data.count > 1)
            {
                self.thumbMedium = data[1][@"uri"];
                
                if(data.count > 2)
                {
                    self.thumbLow = data[2][@"uri"];
                }
            }
        }
        
        if(callback) callback(nil);
    }];
}

- (NSURL *)thumbnailURLForQuality:(YKQualityOptions)quality
{
    switch (quality) {
        case YKQualityHigh:
        {
            if(_thumbHigh)
            {
                return [NSURL URLWithString:_thumbHigh];
            }
        }
        case YKQualityMedium:
        {
            if(_thumbMedium)
            {
                return [NSURL URLWithString:_thumbMedium];
            }
        }
        case YKQualityLow:
        {
            if(_thumbLow)
            {
                return [NSURL URLWithString:_thumbLow];
            }
        }
        default:
            return nil;
            break;
    }
}

- (void)thumbImage:(YKQualityOptions)quality completion:(void(^)(UIImage *thumbImage, NSError *error))callback
{
    NSAssert(callback, @"completion block cannot be nil");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSURL *url = [self thumbnailURLForQuality:quality];
        
        if(!url)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                
                if(callback) callback(nil, nil);
                
            });
            
            return;
        }
        
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            
            if(callback) callback(image, nil);
            
        });
        
    });
}

- (NSURL *)videoURL:(YKQualityOptions)quality
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://www.facebook.com/video/embed?video_id=%@", _identifier]];
//    return self.contentURL;
}

//- (void)play:(YKQualityOptions)quality
//{
////    NSString *html = [NSString stringWithFormat:@"<!DOCTYPE html><html><head><meta name=\"viewport\" content=\"initial-scale = 1.0,maximum-scale = 1.0\" /><style>html, body{background-color:#000;width: 100%%;height:100%%;}</style></head><body>%@</body></html>", _embed];
//    
//    [self presentController:[YKWebViewController modalWithHTML:html] completion:nil];
//}

@end
