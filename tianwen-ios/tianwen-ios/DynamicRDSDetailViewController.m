//
//  DynamicRDSDetailViewController.m
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/22.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "DynamicRDSDetailViewController.h"
#import "TianwenAPI.h"
#import "TianwenHelper.h"
#import "DynamicProgressTableViewCell.h"

@interface DynamicRDSDetailViewController ()

@end

@implementation DynamicRDSDetailViewController

-(instancetype)initWithInstanceId:(NSString *)instanceId andRegionId:(NSString *)regionId forAccount:(AliyunAccountModel *)account{
    self=[super initWithStyle:(UITableViewStyleGrouped)];
    if(self){
        _instanceId=instanceId;
        _regionId=regionId;
        _account=account;
        _navTitle=_instanceId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title=[NSString stringWithFormat:@"%@",_navTitle];
    
    UIActivityIndicatorView*aiv=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    [aiv startAnimating];
    UIBarButtonItem * refreshButton=[[UIBarButtonItem alloc]initWithCustomView:aiv];
    [self.navigationItem setRightBarButtonItem:refreshButton];
    
    [self performSelectorInBackground:@selector(loadDataInBackground) withObject:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadDataInBackground{
    NSDictionary*dict=[TianwenAPI Product:@"rds" instance:_instanceId inRegion:_regionId forAccount:_account];
    
    [self removeAllSectionInfo];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    
    if(!dict){
        NSString * sectionKey=@"ErrorSection";
        
        DynamicTableSectionInfo * errorSectionInfo=[[DynamicTableSectionInfo alloc]initWithSectionKey:sectionKey];
        [errorSectionInfo setTitle:NSLocalizedString(@"Failed",@"失败")];
        [self appendSection:errorSectionInfo];
        
        DynamicTableCellInfo * cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Error" andCellReusableId:@"DynamicRDSDetailViewController_ErrorCell"];
        [cellInfo setText:NSLocalizedString(@"API Call Failed",@"")];
        [self appendCell:cellInfo toSectionWithKey:sectionKey];
    }else if (![[dict objectForKey:@"code"]isEqualToString:@"OK"]){
        NSString * sectionKey=@"ErrorSection";
        
        DynamicTableSectionInfo * errorSectionInfo=[[DynamicTableSectionInfo alloc]initWithSectionKey:sectionKey];
        [errorSectionInfo setTitle:NSLocalizedString(@"Failed",@"失败")];
        [self appendSection:errorSectionInfo];
        
        DynamicTableCellInfo * cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Error" andCellReusableId:@"DynamicRDSDetailViewController_ErrorCell"];
        [cellInfo setText:[NSString stringWithFormat: NSLocalizedString(@"API Error: %@",@""),[dict objectForKey:@"data"]]];
        [self appendCell:cellInfo toSectionWithKey:sectionKey];
    }else{
        NSDictionary * rds=[[dict objectForKey:@"data"]objectForKey:@"rds"];
        NSDictionary*cms=[[dict objectForKey:@"data"]objectForKey:@"cms"];
        
        _navTitle=[NSString stringWithFormat:@"%@",[rds objectForKey:@"DBInstanceDescription"]];
        
        [self makeSectionFromRDSDictionary:rds];
        [self makeSectionFromCMSDictionary:cms];
    }
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    [self performSelectorOnMainThread:@selector(refreshUI) withObject:nil waitUntilDone:NO];
}

-(void)makeSectionFromRDSDictionary:(NSDictionary*)rds{
    DynamicTableSectionInfo * rdsSectionInfo=[[DynamicTableSectionInfo alloc]initWithSectionKey:@"RDSSection"];
    [rdsSectionInfo setTitle:NSLocalizedString(@"RDS Info",@"")];
    
    DynamicTableCellInfo *cellInfo=nil;
    NSString * rds_cell_id=@"DynamicRDSDetailViewController_NormalCell";
    __weak DynamicRDSDetailViewController*weakSelf=self;
    
    _RDSType=[NSString stringWithFormat:@"%@",[rds objectForKey:@"DBInstanceType"]];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"DBInstanceId" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"DBInstanceId",@"")];
    [cellInfo setDetailText:[TianwenHelper hiddenForScreenshot:[NSString stringWithFormat:@"%@",[rds objectForKey:@"DBInstanceId"]]]];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"DBInstanceDescription" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"DBInstanceDescription",@"")];
    [cellInfo setDetailText:[TianwenHelper hiddenForScreenshot:[NSString stringWithFormat:@"%@",[rds objectForKey:@"DBInstanceDescription"]]]];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"DBInstanceClass" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"DBInstanceClass",@"")];
    NSString * rds_instance_class=[NSString stringWithFormat:@"%@",[rds objectForKey:@"DBInstanceClass"]];
    [cellInfo setDetailText:NSLocalizedString(rds_instance_class,@"")];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"DBInstanceType" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"DBInstanceType",@"")];
    NSString * rds_instance_type=[NSString stringWithFormat:@"%@",[rds objectForKey:@"DBInstanceType"]];
    [cellInfo setDetailText:NSLocalizedString(rds_instance_type,@"")];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"ConnectionString" andCellReusableId:@"RDSURLCELL"];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"ConnectionString",@"")];
    [cellInfo setDetailText:[TianwenHelper hiddenForScreenshot:[NSString stringWithFormat:@"%@",[rds objectForKey:@"ConnectionString"]]]];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Port" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"Port",@"")];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[rds objectForKey:@"Port"]]];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Engine" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"Engine",@"")];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@ %@",[rds objectForKey:@"Engine"],[rds objectForKey:@"EngineVersion"]]];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"RegionId" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"RegionId",@"")];
    [cellInfo setDetailText:[AliyunAccountModel getDisplayNameForRegionId:[NSString stringWithFormat:@"%@",[rds objectForKey:@"RegionId"]]]];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"ZoneId" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"ZoneId",@"")];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[rds objectForKey:@"ZoneId"]]];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"DBInstanceMemory" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"DBInstanceMemory",@"")];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@ M",[rds objectForKey:@"DBInstanceMemory"]]];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"DBInstanceStorage" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"DBInstanceStorage",@"")];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@ G",[rds objectForKey:@"DBInstanceStorage"]]];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"MaxIOPS" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"MaxIOPS",@"")];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[rds objectForKey:@"MaxIOPS"]]];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"MaxConnections" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"MaxConnections",@"")];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[rds objectForKey:@"MaxConnections"]]];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"MaintainTime" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"MaintainTime",@"")];
    [cellInfo setDetailText:[[NSString stringWithFormat:@"%@",[rds objectForKey:@"MaintainTime"]]stringByReplacingOccurrencesOfString:@"Z" withString:@""]];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"AvailabilityValue" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"AvailabilityValue",@"")];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[rds objectForKey:@"AvailabilityValue"]]];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"LockMode" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"LockMode",@"")];
    NSString*rds_lock_mode=[NSString stringWithFormat:@"%@",[rds objectForKey:@"LockMode"]];
    [cellInfo setDetailText:NSLocalizedString(rds_lock_mode, @"")];
    [rdsSectionInfo appendCell:cellInfo];
    
    if(![[NSString stringWithFormat:@"%@",[rds objectForKey:@"LockMode"]] isEqualToString:@"Unlock"]){
        NSString * lock_reason=[[rds objectForKey:@"LockReason"] isKindOfClass:[NSNull class]]?@"":[rds objectForKey:@"LockReason"];
        
        cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"LockReason" andCellReusableId:rds_cell_id];
        [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
        [cellInfo setText:NSLocalizedString(@"LockReason",@"")];
        [cellInfo setDetailText:[NSString stringWithFormat:@"%@",lock_reason]];
        [rdsSectionInfo appendCell:cellInfo];
    }
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"CreationTime" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"CreationTime",@"")];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[TianwenHelper localizedDateStringFromISO8601String:[rds objectForKey:@"CreationTime"]]]];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"ExpireTime" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"ExpireTime",@"")];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[TianwenHelper localizedDateStringFromISO8601String:[rds objectForKey:@"ExpireTime"]]]];
    [rdsSectionInfo appendCell:cellInfo];
    
    [self appendSection:rdsSectionInfo];
    
    if([rds objectForKey:@"DBInstanceType"]
       && [[rds objectForKey:@"DBInstanceType"] isEqualToString:@"Primary"]
       && [[rds objectForKey:@"ReadOnlyDBInstanceIds"] isKindOfClass:[NSArray class]]
       && [[rds objectForKey:@"ReadOnlyDBInstanceIds"]count]
       ){
        DynamicTableSectionInfo * roSectionInfo = [[DynamicTableSectionInfo alloc]initWithSectionKey:@"ReadOnlyDBInstanceIds"];
        [roSectionInfo setTitle:NSLocalizedString(@"ReadOnly Instances",@"")];
        
        for (NSUInteger i=0; i<[[rds objectForKey:@"ReadOnlyDBInstanceIds"]count]; i++) {
            NSString*roId=[[rds objectForKey:@"ReadOnlyDBInstanceIds"]objectAtIndex:i];
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:roId andCellReusableId:rds_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setText:@"ID"];
            [cellInfo setDetailText:[NSString stringWithFormat:@"%@",roId]];
            
            [cellInfo setOnSelect:^(DynamicTableCellInfo* _Nonnull cellInfo, id _Nullable otherInfo){
                DynamicRDSDetailViewController * rdsVC=[[DynamicRDSDetailViewController alloc]initWithInstanceId:roId andRegionId:_regionId forAccount:_account];
                [[weakSelf navigationController]pushViewController:rdsVC animated:YES];
            }];
            
            [roSectionInfo appendCell:cellInfo];
        }
        
        [self appendSection:roSectionInfo];
    }
    
}
-(void)makeSectionFromCMSDictionary:(NSDictionary*)cms{
    DynamicTableSectionInfo * cmsSectionInfo=[[DynamicTableSectionInfo alloc]initWithSectionKey:@"CMSSection"];
    [cmsSectionInfo setTitle:NSLocalizedString(@"Current Status",@"")];
    
    DynamicTableCellInfo *cellInfo=nil;
    NSString * cms_cell_id=@"DynamicRDSDetailViewController_NormalCell";
    NSString * err_cell_id=@"DynamicRDSDetailViewController_ErrorCell";
    {
        id cpu=[cms objectForKey:@"cpu"];
        if([cpu isKindOfClass:[NSDictionary class]]){
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"CPU" andCellReusableId:cms_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setText:NSLocalizedString(@"CPU Usage Average",@"")];
            [cellInfo setDetailText:[NSString stringWithFormat:@"%@%%",[cpu objectForKey:@"Average"]]];
            [cellInfo setAdditionCellSettingsBlock:^(__kindof DynamicTableCellInfoCompatibleCell* _Nonnull cell){
                DynamicProgressTableViewCell * dptvc=(DynamicProgressTableViewCell*)cell;
                CGFloat progress=[[NSString stringWithFormat:@"%@",[cpu objectForKey:@"Average"]]floatValue]/100.0;
                NSLog(@"progress: %f",progress);
                UIColor * color=[TianwenHelper colorForProgressRate:progress];
                [dptvc setProgress:progress andColor:color];
            }];
        }else if([cpu isKindOfClass:[NSString class]]){
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"CPU-ERROR" andCellReusableId:err_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setText:NSLocalizedString(@"CPU Usage Average",@"")];
            [cellInfo setDetailText:cpu];
        }
        [cmsSectionInfo appendCell:cellInfo];
    }
    {
        id memory = [cms objectForKey:@"memory"];
        if([memory isKindOfClass:[NSDictionary class]]){
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Memory" andCellReusableId:cms_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setText:NSLocalizedString(@"Memory Usage Average",@"")];
            [cellInfo setDetailText:[NSString stringWithFormat:@"%@%%",[memory objectForKey:@"Average"]]];
            [cellInfo setAdditionCellSettingsBlock:^(__kindof DynamicTableCellInfoCompatibleCell* _Nonnull cell){
                DynamicProgressTableViewCell * dptvc=(DynamicProgressTableViewCell*)cell;
                CGFloat progress=[[NSString stringWithFormat:@"%@",[memory objectForKey:@"Average"]]floatValue]/100.0;
                NSLog(@"progress: %f",progress);
                UIColor * color=[TianwenHelper colorForProgressRate:progress];
                [dptvc setProgress:progress andColor:color];
            }];
        }else if([memory isKindOfClass:[NSString class]]){
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Memory-ERROR" andCellReusableId:err_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setText:NSLocalizedString(@"Memory Usage Average",@"")];
            [cellInfo setDetailText:memory];
        }
        [cmsSectionInfo appendCell:cellInfo];
    }
    {
        id disk = [cms objectForKey:@"disk"];
        if([disk isKindOfClass:[NSDictionary class]]){
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Disk" andCellReusableId:cms_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setText:NSLocalizedString(@"Disk Usage Average",@"")];
            [cellInfo setDetailText:[NSString stringWithFormat:@"(%@ %@ GB) %@%%",NSLocalizedString(@"Left", @"可用"),[disk objectForKey:@"freeSpace"],[disk objectForKey:@"Average"]]];
            [cellInfo setAdditionCellSettingsBlock:^(__kindof DynamicTableCellInfoCompatibleCell* _Nonnull cell){
                DynamicProgressTableViewCell * dptvc=(DynamicProgressTableViewCell*)cell;
                CGFloat progress=[[NSString stringWithFormat:@"%@",[disk objectForKey:@"Average"]]floatValue]/100.0;
                NSLog(@"progress: %f",progress);
                UIColor * color=[TianwenHelper colorForProgressRate:progress];
                [dptvc setProgress:progress andColor:color];
            }];
        }else if([disk isKindOfClass:[NSString class]]){
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Disk-ERROR" andCellReusableId:err_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setText:NSLocalizedString(@"Disk Usage Average",@"")];
            [cellInfo setDetailText:disk];
        }
        [cmsSectionInfo appendCell:cellInfo];
    }
    {
        id connection = [cms objectForKey:@"connection"];
        if([connection isKindOfClass:[NSDictionary class]]){
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Connection" andCellReusableId:cms_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setText:NSLocalizedString(@"Connection Usage Average",@"")];
            [cellInfo setDetailText:[NSString stringWithFormat:@"%@%%",[connection objectForKey:@"Average"]]];
            [cellInfo setAdditionCellSettingsBlock:^(__kindof DynamicTableCellInfoCompatibleCell* _Nonnull cell){
                DynamicProgressTableViewCell * dptvc=(DynamicProgressTableViewCell*)cell;
                CGFloat progress=[[NSString stringWithFormat:@"%@",[connection objectForKey:@"Average"]]floatValue]/100.0;
                NSLog(@"progress: %f",progress);
                UIColor * color=[TianwenHelper colorForProgressRate:progress];
                [dptvc setProgress:progress andColor:color];
            }];
        }else if([connection isKindOfClass:[NSString class]]){
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Connection-ERROR" andCellReusableId:err_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setDetailText:connection];
            [cellInfo setText:NSLocalizedString(@"Connection Usage Average",@"")];
        }
        [cmsSectionInfo appendCell:cellInfo];
    }
    {
        id iops = [cms objectForKey:@"iops"];
        if([iops isKindOfClass:[NSDictionary class]]){
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"IOPS" andCellReusableId:cms_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setText:NSLocalizedString(@"IOPS Usage Average",@"")];
            [cellInfo setDetailText:[NSString stringWithFormat:@"%@%%",[iops objectForKey:@"Average"]]];
            [cellInfo setAdditionCellSettingsBlock:^(__kindof DynamicTableCellInfoCompatibleCell* _Nonnull cell){
                DynamicProgressTableViewCell * dptvc=(DynamicProgressTableViewCell*)cell;
                CGFloat progress=[[NSString stringWithFormat:@"%@",[iops objectForKey:@"Average"]]floatValue]/100.0;
                NSLog(@"progress: %f",progress);
                UIColor * color=[TianwenHelper colorForProgressRate:progress];
                [dptvc setProgress:progress andColor:color];
            }];
        }else if([iops isKindOfClass:[NSString class]]){
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"IOPS-ERROR" andCellReusableId:err_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setText:NSLocalizedString(@"IOPS Usage Average",@"")];
            [cellInfo setDetailText:iops];
        }
        [cmsSectionInfo appendCell:cellInfo];
    }
    if([_RDSType isEqualToString:@"Readonly"]){
        id delay = [cms objectForKey:@"delay"];
        if([delay isKindOfClass:[NSDictionary class]]){
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Delay" andCellReusableId:cms_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setText:NSLocalizedString(@"Data Delay Average",@"")];
            [cellInfo setDetailText:[NSString stringWithFormat:@"%@ s",[delay objectForKey:@"Average"]]];
        }else if([delay isKindOfClass:[NSString class]]){
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Delay-ERROR" andCellReusableId:err_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setText:NSLocalizedString(@"Data Delay Average",@"")];
            [cellInfo setDetailText:delay];
        }
        [cmsSectionInfo appendCell:cellInfo];
    }
    
    [self appendSection:cmsSectionInfo];
}

-(void)refreshUI{
    [self.navigationItem setTitle:_navTitle];
    
    UIBarButtonItem * refreshButton=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:(UIBarButtonSystemItemRefresh) target:self action:@selector(onRefreshButton:)];
    [self.navigationItem setRightBarButtonItem:refreshButton];
}

-(void)onRefreshButton:(id)sender{
    UIActivityIndicatorView*aiv=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    [aiv startAnimating];
    UIBarButtonItem * refreshButton=[[UIBarButtonItem alloc]initWithCustomView:aiv];
    [self.navigationItem setRightBarButtonItem:refreshButton];
    
    //[self removeAllSectionInfo];
    //[self.tableView reloadData];
    
    [self performSelectorInBackground:@selector(loadDataInBackground) withObject:nil];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

-(UITableViewCell *)createReusableCellWithStyle:(UITableViewCellStyle)cellStyle reuseIdentifier:(NSString *)cellReusableId{
    return [[DynamicProgressTableViewCell alloc]initWithStyle:cellStyle reuseIdentifier:cellReusableId];
}

@end
