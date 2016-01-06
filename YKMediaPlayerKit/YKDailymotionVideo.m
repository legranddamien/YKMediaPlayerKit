//
//  YKDailymotionVideo.m
//  Pods
//
//  Created by Damien Legrand on 05/01/2016.
//
//

#import "YKDailymotionVideo.h"
#import "YKHelper.h"

@interface YKDailymotionVideo ()

@property (nonatomic, strong) NSDictionary *data;

@property (nonatomic) BOOL parsed;

@end

@implementation YKDailymotionVideo

- (void)parseWithCompletion:(void(^)(NSError *error))callback
{
    NSAssert(self.contentURL, @"Invalid contentURL");
    
    if(_parsed)
    {
        if(callback) callback(nil);
    }
    
    _parsed = YES;
    
    NSString *lastPathComponent = self.contentURL.lastPathComponent;
    NSArray *exploded = [lastPathComponent componentsSeparatedByString:@"_"];
    NSString *identifier = exploded[0];

    
    NSString *apiURL = [NSString stringWithFormat:@"https://api.dailymotion.com/video/%@?fields=embed_url,thumbnail_360_url,thumbnail_480_url,thumbnail_720_url", identifier];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:apiURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(error)
        {
            if(callback) callback(error);
            return;
        }
        
        NSError *jsonError;
        _data = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
        
        if(jsonError)
        {
            if(callback) callback(jsonError);
            return;
        }
        
        if(callback) callback(nil);
        
    }];
    
    [task resume];
}

- (NSURL *)thumbnailURLForQuality:(YKQualityOptions)quality
{
    if(!self.data) return nil;
    
    switch (quality) {
        case YKQualityHigh:{
            
            if(self.data[@"thumbnail_720_url"])
            {
                return [NSURL URLWithString:self.data[@"thumbnail_720_url"]];
            }
            
        }
            
        case YKQualityMedium:{
            
            if(self.data[@"thumbnail_480_url"])
            {
                return [NSURL URLWithString:self.data[@"thumbnail_480_url"]];
            }
            
        }
            
        case YKQualityLow:{
            
            if(self.data[@"thumbnail_360_url"])
            {
                return [NSURL URLWithString:self.data[@"thumbnail_360_url"]];
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

- (NSURL *)videoURL:(YKQualityOptions)quality {
    
    if(self.data && self.data[@"embed_url"])
    {
        if(YK_IOS8)
        {
            return [NSURL URLWithString:[self.data[@"embed_url"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        }
        else
        {
            _Pragma("clang diagnostic push")
            _Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"")
            return [NSURL URLWithString:[self.data[@"embed_url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            _Pragma("clang diagnostic pop")
        }
    }
    
    return self.contentURL;
}

@end
