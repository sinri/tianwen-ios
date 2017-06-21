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

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [[self navigationItem ]setTitle:@"Settings"];
    
    _table=[[UITableView alloc]initWithFrame:(CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)) style:(UITableViewStyleGrouped)];
    [_table setDelegate:self];
    [_table setDataSource:self];
    [self.view addSubview:_table];
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
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[AliyunAccountModel storedAccounts]count]+1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:@"SettingsTableCell"];
    if(!cell){
        cell=[[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleValue1) reuseIdentifier:@"SettingsTableCell"];
    }
    
    if([indexPath section]==0){
        if([[AliyunAccountModel storedAccounts]count]==[indexPath row]){
            //add one more
            [[cell textLabel]setText:@"Add account..."];
        }else{
            AliyunAccountModel*aam=[self getAliyunAccountModelAtOrder:indexPath.row];
            if([aam isAKMode]){
                [[cell detailTextLabel]setText:@"AccessKey Pair"];
            }else if ([aam isUPMode]){
                [[cell detailTextLabel]setText:@"Registered User"];
            }
            [[cell textLabel]setText:aam.nickname];
        }
    }
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section==0){
        return @"Account";
    }
    
    return @"";
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([indexPath section]==0){
        //account
        AliyunAccountModel*aam=nil;
        if([indexPath row]<[[AliyunAccountModel storedAccounts]count]){
            aam=[self getAliyunAccountModelAtOrder:indexPath.row];
        }
        AddAccountViewController*aavc=[[AddAccountViewController alloc]initWithAliyunAccountModel:aam];
        [self.navigationController pushViewController:aavc animated:YES];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if([indexPath section]==0){
        //account
        if([indexPath row]<[[AliyunAccountModel storedAccounts]count]){
            return YES;
        }
    }
    return NO;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([indexPath section]==0){
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
            if(indexPath.section==0){
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

@end
