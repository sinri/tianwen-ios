//
//  AboutViewController.m
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/23.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "AboutViewController.h"

#import <Crashlytics/Crashlytics.h>

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.navigationItem.title=NSLocalizedString(@"About Tianwen",@"应用信息");
    
    _webView=[[UIWebView alloc]initWithFrame:(CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))];
    [[_webView scrollView]setBounces:NO];
    [_webView setDelegate:self];
    [self.view addSubview:_webView];
    
    [self refreshAboutPage:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    UIActivityIndicatorView*aiv=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    [aiv startAnimating];
    UIBarButtonItem * refreshButton=[[UIBarButtonItem alloc]initWithCustomView:aiv];
    [self.navigationItem setRightBarButtonItem:refreshButton];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    self.navigationItem.rightBarButtonItem=nil;
    
    [Answers logCustomEventWithName:@"Display Readme" customAttributes:@{}];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    UIBarButtonItem * refrsshButton=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:(UIBarButtonSystemItemRefresh) target:self action:@selector(refreshAboutPage:)];
    self.navigationItem.rightBarButtonItem=refrsshButton;
}

-(void)refreshAboutPage:(id)sender{
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://tianwen.sinri.cc/iosAboutPage.php"]]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
