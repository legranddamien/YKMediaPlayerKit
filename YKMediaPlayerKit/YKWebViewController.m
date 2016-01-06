//
//  YKWebViewController.m
//  Pods
//
//  Created by Damien Legrand on 05/01/2016.
//
//

#import "YKWebViewController.h"

@interface YKWebViewController ()

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation YKWebViewController

+ (UINavigationController *)modalWithURL:(NSURL *)url
{
    YKWebViewController *controller = [[YKWebViewController alloc] initWithNibName:nil bundle:nil];
    controller.url = url;
    return [[UINavigationController alloc] initWithRootViewController:controller];
}

+ (UINavigationController *)modalWithHTML:(NSString *)html
{
    YKWebViewController *controller = [[YKWebViewController alloc] initWithNibName:nil bundle:nil];
    controller.html = html;
    return [[UINavigationController alloc] initWithRootViewController:controller];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                          target:self
                                                                                          action:@selector(dismiss)];
    
    self.webView = [[UIWebView alloc] init];
    self.webView.scalesPageToFit = YES;
    
    if(_url)
    {
        [self.webView loadRequest:[NSURLRequest requestWithURL:_url]];
    }
    else if (_html)
    {
        [self.webView loadHTMLString:_html baseURL:nil];
    }
    
    [self.view addSubview:self.webView];
    
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
