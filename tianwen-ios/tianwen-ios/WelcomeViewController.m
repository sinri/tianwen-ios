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
#import "TianwenSettings.h"
//#import "TianwenWarningInfoView.h"
#import "AccountProductViewController.h"

#import "DynamicECSDetailViewController.h"
#import "DynamicRDSDetailViewController.h"
#import "DynamicREDISDetailViewController.h"
#import "DynamicSLBDetailViewController.h"

#import "AddAccountViewController.h"

@interface WelcomeViewController ()
@property NSString * currentWarningStyle;
@property NSInteger currentAccountCount;
@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [[self navigationItem]setTitle:NSLocalizedString(@"Tianwen",@"天问")];
    
    UIBarButtonItem*settingBarItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(onSettingBarItem:)];
    [[self navigationItem]setRightBarButtonItem:settingBarItem];
    
    UIBarButtonItem*productsBarItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:(UIBarButtonSystemItemOrganize) target:self action:@selector(onProductsBarItem:)];
    [[self navigationItem]setLeftBarButtonItem:productsBarItem];
    
    _currentWarningStyle=[TianwenSettings warningDisplayStyle];
    
    NSArray*accounts=[[AliyunAccountModel storedAccounts] allValues];
    
    _warningReportView=[[DynamicTianwenWarningView alloc]initWithFrame:(CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))];
    [_warningReportView setDelegate:self];
    [_warningReportView loadDataForAccounts:accounts];
    [self.view addSubview:_warningReportView];
    
    _currentAccountCount=[accounts count];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"appear: old account count=%ld",(long)_currentAccountCount);
    NSLog(@"appear: now account count=%ld",(long)[[[AliyunAccountModel storedAccounts] allValues] count]);
    if(
       (![_currentWarningStyle isEqualToString:[TianwenSettings warningDisplayStyle]])
       || (_currentAccountCount!=[[[AliyunAccountModel storedAccounts] allValues] count])
    ){
        NSLog(@"appear reloading");
        [_warningReportView reloadData];
        _currentAccountCount=[[[AliyunAccountModel storedAccounts] allValues] count];
    }
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

-(void)onProductsBarItem:(id)sender{
    AccountProductViewController * apvc=[[AccountProductViewController alloc]initWithStyle:(UITableViewStyleGrouped)];
    [[self navigationController]pushViewController:apvc animated:YES];
}

-(NSArray<AliyunAccountModel *> *)reloadAccountsForDynamicTianwenWarningView:(DynamicTianwenWarningView *)target{
    return [[AliyunAccountModel storedAccounts] allValues];
}

-(void)onSelectWarning:(DynamicTianwenWarningView *)target cellInfo:(DynamicTableCellInfo *)cellInfo addition:(NSDictionary *)addition{
    NSLog(@"onSelectWarning --> %@",addition);
    if([[[addition objectForKey:@"warning"] objectForKey:@"hardware_type"]isEqualToString:@"ECS"]){
        DynamicECSDetailViewController*vc=[[DynamicECSDetailViewController alloc]initWithInstanceId:[[addition objectForKey:@"warning"]objectForKey:@"instance_id"] andRegionId:[[addition objectForKey:@"warning"] objectForKey:@"region_id"] forAccount:[addition objectForKey:@"account"]];
        [[self navigationController]pushViewController:vc animated:YES];
    }else if([[[addition objectForKey:@"warning"] objectForKey:@"hardware_type"]isEqualToString:@"RDS"]){
        DynamicRDSDetailViewController*vc=[[DynamicRDSDetailViewController alloc]initWithInstanceId:[[addition objectForKey:@"warning"]objectForKey:@"instance_id"] andRegionId:[[addition objectForKey:@"warning"] objectForKey:@"region_id"] forAccount:[addition objectForKey:@"account"]];
        [[self navigationController]pushViewController:vc animated:YES];
    }else if([[[addition objectForKey:@"warning"] objectForKey:@"hardware_type"]isEqualToString:@"REDIS"]){
        DynamicREDISDetailViewController*vc=[[DynamicREDISDetailViewController alloc]initWithInstanceId:[[addition objectForKey:@"warning"]objectForKey:@"instance_id"] andRegionId:[[addition objectForKey:@"warning"] objectForKey:@"region_id"] forAccount:[addition objectForKey:@"account"]];
        [[self navigationController]pushViewController:vc animated:YES];
    }else if([[[addition objectForKey:@"warning"] objectForKey:@"hardware_type"]isEqualToString:@"SLB"]){
        DynamicSLBDetailViewController*vc=[[DynamicSLBDetailViewController alloc]initWithInstanceId:[[addition objectForKey:@"warning"]objectForKey:@"instance_id"] andRegionId:[[addition objectForKey:@"warning"] objectForKey:@"region_id"] forAccount:[addition objectForKey:@"account"]];
        [[self navigationController]pushViewController:vc animated:YES];
    }

}

-(void)onAddAccountButton{
    NSLog(@"current account count=%ld",(long)_currentAccountCount);
    AddAccountViewController * aavc=[[AddAccountViewController alloc]initWithAliyunAccountModel:nil];
    [self.navigationController pushViewController:aavc animated:YES];
}

@end
