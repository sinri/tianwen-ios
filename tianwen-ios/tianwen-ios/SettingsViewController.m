//
//  SettingsViewController.m
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/18.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "SettingsViewController.h"
#import "AliyunAccountModel.h"
#import "AddAccountViewController.h"
#import "AboutViewController.h"
#import "TianwenSettings.h"
#import <Crashlytics/Crashlytics.h>

#define SETTING_TABLE_SECTION_INDEX_OF_ACCOUNTS 0
#define SETTING_TABLE_SECTION_INDEX_OF_WARNING_VIEW_STYLE 1
#define SETTING_TABLE_SECTION_INDEX_OF_ABOUT 2

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [[self navigationItem ]setTitle:NSLocalizedString(@"Settings",@"设置")];
    
    //CGRect appFrame=[UIScreen mainScreen].applicationFrame;
    
    CGFloat adViewHeight=[SinriAdView recommendedBannerHeight];
    
    CGRect tableFrame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-adViewHeight);
    
    _table=[[UITableView alloc]initWithFrame:tableFrame style:(UITableViewStyleGrouped)];
    [_table setDelegate:self];
    [_table setDataSource:self];
    [self.view addSubview:_table];
    
    _adView = [[SinriAdView alloc]initWithFrame:(CGRectMake(0, self.view.frame.size.height-adViewHeight, self.view.frame.size.width, adViewHeight))];
    [_adView setUseAdMob:YES];
    [_adView setGAD_APP_ID:@"ca-app-pub-5323203756742073~1478169140"];
    [_adView setGAD_UNIT_ID:@"ca-app-pub-5323203756742073/4431635545"];
    [_adView setRootViewController:self];
    [self.view addSubview:_adView];
}

-(AliyunAccountModel*)getAliyunAccountModelAtOrder:(NSUInteger)index{
    NSDictionary<NSString*,AliyunAccountModel*>*dict=[AliyunAccountModel storedAccounts];
    NSString*key=[[dict allKeys]objectAtIndex:index];
    AliyunAccountModel*aam=[dict objectForKey:key];
    return aam;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [_table reloadData];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section==SETTING_TABLE_SECTION_INDEX_OF_ACCOUNTS){
        return [[AliyunAccountModel storedAccounts]count]+1;
    }
    else if(section==SETTING_TABLE_SECTION_INDEX_OF_WARNING_VIEW_STYLE){
        return 2;
    }
    else if(section==SETTING_TABLE_SECTION_INDEX_OF_ABOUT){
        return 1;
    }
    else return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:@"SettingsTableCell"];
    if(!cell){
        cell=[[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleValue1) reuseIdentifier:@"SettingsTableCell"];
    }
    
    if([indexPath section]==SETTING_TABLE_SECTION_INDEX_OF_ACCOUNTS){
        if([[AliyunAccountModel storedAccounts]count]==[indexPath row]){
            //add one more
            [[cell textLabel]setText:NSLocalizedString(@"Add Account",@"添加账户")];
            [[cell detailTextLabel]setText:nil];
            [cell setAccessoryType:(UITableViewCellAccessoryDisclosureIndicator)];
        }else{
            AliyunAccountModel*aam=[self getAliyunAccountModelAtOrder:indexPath.row];
            if([aam isAKMode]){
                [[cell detailTextLabel]setText:NSLocalizedString(@"AccessKey Pair",@"阿里云子账号")];
            }else if ([aam isUPMode]){
                [[cell detailTextLabel]setText:NSLocalizedString(@"Registered User",@"注册账户")];
            }
            [[cell textLabel]setText:aam.nickname];
            [cell setAccessoryType:(UITableViewCellAccessoryDetailButton)];
        }
    }
    else if([indexPath section]==SETTING_TABLE_SECTION_INDEX_OF_WARNING_VIEW_STYLE){
        [[cell detailTextLabel]setText:nil];
        [cell setAccessoryType:(UITableViewCellAccessoryNone)];
        if(indexPath.row==0){
            [[cell textLabel]setText:NSLocalizedString(@"List Mode",@"以列表形式展示")];
            if([[TianwenSettings warningDisplayStyle]isEqualToString:@"WarningDisplayStyleList"]){
                [cell setAccessoryType:(UITableViewCellAccessoryCheckmark)];
            }
        }else if (indexPath.row==1){
            [[cell textLabel]setText:NSLocalizedString(@"Tree Mode",@"以分组形式展示")];
            if([[TianwenSettings warningDisplayStyle]isEqualToString:@"WarningDisplayStyleTree"]){
                [cell setAccessoryType:(UITableViewCellAccessoryCheckmark)];
            }
        }
    }
    else if([indexPath section]==SETTING_TABLE_SECTION_INDEX_OF_ABOUT){
        //readme
        [[cell textLabel]setText:NSLocalizedString(@"About Tianwen",@"应用信息")];
        [[cell detailTextLabel]setText:nil];
        [cell setAccessoryType:(UITableViewCellAccessoryDisclosureIndicator)];
    }
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section==SETTING_TABLE_SECTION_INDEX_OF_ACCOUNTS){
        return NSLocalizedString(@"Account",@"账户");
    }
    else if(section==SETTING_TABLE_SECTION_INDEX_OF_WARNING_VIEW_STYLE){
        return NSLocalizedString(@"Warning View Style",@"警报视图样式");
    }
    else if(section==SETTING_TABLE_SECTION_INDEX_OF_ABOUT){
        return NSLocalizedString(@"Information",@"信息");
    }
    
    return @"";
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([indexPath section]==SETTING_TABLE_SECTION_INDEX_OF_ACCOUNTS){
        //account
        AliyunAccountModel*aam=nil;
        if([indexPath row]<[[AliyunAccountModel storedAccounts]count]){
            aam=[self getAliyunAccountModelAtOrder:indexPath.row];
        }
        AddAccountViewController*aavc=[[AddAccountViewController alloc]initWithAliyunAccountModel:aam];
        [self.navigationController pushViewController:aavc animated:YES];
    }
    else if([indexPath section]==SETTING_TABLE_SECTION_INDEX_OF_WARNING_VIEW_STYLE){
        
        NSString*original_wds=[TianwenSettings warningDisplayStyle];
        
        if([indexPath row]==0){
            [TianwenSettings setWarningDisplayStyle:@"WarningDisplayStyleList"];
        }else if ([indexPath row]==1){
            [TianwenSettings setWarningDisplayStyle:@"WarningDisplayStyleTree"];
        }
        
        if(![original_wds isEqualToString:[TianwenSettings warningDisplayStyle]]){
            [Answers logCustomEventWithName:@"Change WarningDisplayStyle"customAttributes:@{@"target style":[TianwenSettings warningDisplayStyle]}];
        }
        
        [tableView reloadData];
    }
    else if([indexPath section]==SETTING_TABLE_SECTION_INDEX_OF_ABOUT){
        //about
        AboutViewController * avc=[[AboutViewController alloc]init];
        [[self navigationController]pushViewController:avc animated:YES];
    }
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if([indexPath section]==SETTING_TABLE_SECTION_INDEX_OF_ACCOUNTS){
        //account
        if([indexPath row]<[[AliyunAccountModel storedAccounts]count]){
            return YES;
        }
    }
    return NO;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([indexPath section]==SETTING_TABLE_SECTION_INDEX_OF_ACCOUNTS){
        //account
        if([indexPath row]<[[AliyunAccountModel storedAccounts]count]){
            return UITableViewCellEditingStyleDelete;
        }
    }
    return UITableViewCellEditingStyleNone;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete:
            if(indexPath.section==SETTING_TABLE_SECTION_INDEX_OF_ACCOUNTS){
                //修改数据源，在刷新 tableView
                [AliyunAccountModel removeAccountInStore:[[self getAliyunAccountModelAtOrder:indexPath.row]computeAliyunAccountModelKey]];
            }
            //让表视图删除对应的行
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            break;
    }
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    if([indexPath section]==SETTING_TABLE_SECTION_INDEX_OF_ACCOUNTS){
        [self tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

@end
