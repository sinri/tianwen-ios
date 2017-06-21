//
//  WelcomeViewController.m
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/18.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "WelcomeViewController.h"
#import "AliyunAccountModel.h"
#import "SettingsViewController.h"
#import "TianwenAPI.h"
#import "TianwenWarningInfoView.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [[self navigationItem]setTitle:@"Tianwen"];
    UIBarButtonItem*settingBarItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(onSettingBarItem:)];
    [[self navigationItem]setRightBarButtonItem:settingBarItem];
    
    _warningReportView=[[TianwenMultiWarningInfoView alloc]initWithFrame:(CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))];
    [_warningReportView setDelegate:self];
    [_warningReportView loadDataForAccounts:[[AliyunAccountModel storedAccounts] allValues]];
    [self.view addSubview:_warningReportView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

-(void)onSettingBarItem:(id)sender{
    SettingsViewController * svc=[[SettingsViewController alloc]init];
    [[self navigationController]pushViewController:svc animated:YES];
}

-(NSArray<AliyunAccountModel *> *)reloadAccountsForTianwenMultiWarningInfoView:(TianwenMultiWarningInfoView *)target{
    return [[AliyunAccountModel storedAccounts] allValues];
}

@end
