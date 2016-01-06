//
//  YKWebViewController.h
//  Pods
//
//  Created by Damien Legrand on 05/01/2016.
//
//

#import <UIKit/UIKit.h>

@interface YKWebViewController : UIViewController

+ (UINavigationController *)modalWithURL:(NSURL *)url;
+ (UINavigationController *)modalWithHTML:(NSString *)html;

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *html;

@end