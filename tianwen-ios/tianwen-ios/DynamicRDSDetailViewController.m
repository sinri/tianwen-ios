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
        [errorSectionInfo setTitle:sectionKey];
        [self appendSection:errorSectionInfo];
        
        DynamicTableCellInfo * cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Error" andCellReusableId:@"DynamicRDSDetailViewController_ErrorCell"];
        [cellInfo setText:@"API Call Failed"];
        [self appendCell:cellInfo toSectionWithKey:sectionKey];
    }else if (![[dict objectForKey:@"code"]isEqualToString:@"OK"]){
        NSString * sectionKey=@"ErrorSection";
        
        DynamicTableSectionInfo * errorSectionInfo=[[DynamicTableSectionInfo alloc]initWithSectionKey:sectionKey];
        [errorSectionInfo setTitle:sectionKey];
        [self appendSection:errorSectionInfo];
        
        DynamicTableCellInfo * cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Error" andCellReusableId:@"DynamicRDSDetailViewController_ErrorCell"];
        [cellInfo setText:[NSString stringWithFormat: @"API Error: %@",[dict objectForKey:@"data"]]];
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
    [rdsSectionInfo setTitle:@"RDS Info"];
    
    DynamicTableCellInfo *cellInfo=nil;
    NSString * rds_cell_id=@"DynamicRDSDetailViewController_NormalCell";
    __weak DynamicRDSDetailViewController*weakSelf=self;
    
    _RDSType=[NSString stringWithFormat:@"%@",[rds objectForKey:@"DBInstanceType"]];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"DBInstanceId" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"DBInstanceId"];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[rds objectForKey:@"DBInstanceId"]]];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"DBInstanceDescription" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"DBInstanceDescription"];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[rds objectForKey:@"DBInstanceDescription"]]];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"DBInstanceType" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"DBInstanceType"];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[rds objectForKey:@"DBInstanceType"]]];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"ConnectionString" andCellReusableId:@"RDSURLCELL"];
    [cellInfo setCellStyle:(UITableViewCellStyleSubtitle)];
    [cellInfo setText:@"ConnectionString"];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[rds objectForKey:@"ConnectionString"]]];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Port" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"Port"];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[rds objectForKey:@"Port"]]];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Engine" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"Engine"];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@ %@",[rds objectForKey:@"Engine"],[rds objectForKey:@"EngineVersion"]]];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"RegionId" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"RegionId"];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[rds objectForKey:@"RegionId"]]];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"ZoneId" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"ZoneId"];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[rds objectForKey:@"ZoneId"]]];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"DBInstanceMemory" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"DBInstanceMemory"];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[rds objectForKey:@"DBInstanceMemory"]]];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"DBInstanceStorage" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"DBInstanceStorage"];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[rds objectForKey:@"DBInstanceStorage"]]];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"MaxIOPS" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"MaxIOPS"];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[rds objectForKey:@"MaxIOPS"]]];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"MaxConnections" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"MaxConnections"];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[rds objectForKey:@"MaxConnections"]]];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"MaintainTime" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"MaintainTime"];
    [cellInfo setDetailText:[[NSString stringWithFormat:@"%@",[rds objectForKey:@"MaintainTime"]]stringByReplacingOccurrencesOfString:@"Z" withString:@""]];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"AvailabilityValue" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"AvailabilityValue"];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[rds objectForKey:@"AvailabilityValue"]]];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"LockMode" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"LockMode"];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[rds objectForKey:@"LockMode"]]];
    [rdsSectionInfo appendCell:cellInfo];
    
    if(![[NSString stringWithFormat:@"%@",[rds objectForKey:@"LockMode"]] isEqualToString:@"Unlock"]){
        NSString * lock_reason=[[rds objectForKey:@"LockReason"] isKindOfClass:[NSNull class]]?@"":[rds objectForKey:@"LockReason"];
        
        cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"LockReason" andCellReusableId:rds_cell_id];
        [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
        [cellInfo setText:@"LockReason"];
        [cellInfo setDetailText:[NSString stringWithFormat:@"%@",lock_reason]];
        [rdsSectionInfo appendCell:cellInfo];
    }
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"CreationTime" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"CreationTime"];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[TianwenHelper localizedDateStringFromISO8601String:[rds objectForKey:@"CreationTime"]]]];
    [rdsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"ExpireTime" andCellReusableId:rds_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"ExpireTime"];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[TianwenHelper localizedDateStringFromISO8601String:[rds objectForKey:@"ExpireTime"]]]];
    [rdsSectionInfo appendCell:cellInfo];
    
    [self appendSection:rdsSectionInfo];
    
    if([rds objectForKey:@"DBInstanceType"]
       && [[rds objectForKey:@"DBInstanceType"] isEqualToString:@"Primary"]
       && [[rds objectForKey:@"ReadOnlyDBInstanceIds"] isKindOfClass:[NSArray class]]
       && [[rds objectForKey:@"ReadOnlyDBInstanceIds"]count]
       ){
        DynamicTableSectionInfo * roSectionInfo = [[DynamicTableSectionInfo alloc]initWithSectionKey:@"ReadOnlyDBInstanceIds"];
        [roSectionInfo setTitle:@"ReadOnly Instances"];
        
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
    [cmsSectionInfo setTitle:@"Current Status"];
    
    DynamicTableCellInfo *cellInfo=nil;
    NSString * cms_cell_id=@"DynamicRDSDetailViewController_NormalCell";
    NSString * err_cell_id=@"DynamicRDSDetailViewController_ErrorCell";
    {
        id cpu=[cms objectForKey:@"cpu"];
        if([cpu isKindOfClass:[NSDictionary class]]){
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"CPU" andCellReusableId:cms_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setText:@"CPU Usage Average"];
            [cellInfo setDetailText:[NSString stringWithFormat:@"%@%%",[cpu objectForKey:@"Average"]]];
        }else if([cpu isKindOfClass:[NSString class]]){
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"CPU-ERROR" andCellReusableId:err_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setText:@"CPU Usage Average"];
            [cellInfo setDetailText:cpu];
        }
        [cmsSectionInfo appendCell:cellInfo];
    }
    {
        id memory = [cms objectForKey:@"memory"];
        if([memory isKindOfClass:[NSDictionary class]]){
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Memory" andCellReusableId:cms_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setText:@"Memory Usage Average"];
            [cellInfo setDetailText:[NSString stringWithFormat:@"%@%%",[memory objectForKey:@"Average"]]];
        }else if([memory isKindOfClass:[NSString class]]){
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Memory-ERROR" andCellReusableId:err_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setText:@"Memory Usage Average"];
            [cellInfo setDetailText:memory];
        }
        [cmsSectionInfo appendCell:cellInfo];
    }
    {
        id disk = [cms objectForKey:@"disk"];
        if([disk isKindOfClass:[NSDictionary class]]){
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Disk" andCellReusableId:cms_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setText:@"Disk Usage Average"];
            [cellInfo setDetailText:[NSString stringWithFormat:@"%@%%",[disk objectForKey:@"Average"]]];
        }else if([disk isKindOfClass:[NSString class]]){
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Disk-ERROR" andCellReusableId:err_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setText:@"Disk Usage Average"];
            [cellInfo setDetailText:disk];
        }
        [cmsSectionInfo appendCell:cellInfo];
    }
    {
        id connection = [cms objectForKey:@"connection"];
        if([connection isKindOfClass:[NSDictionary class]]){
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Connection" andCellReusableId:cms_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setText:@"Connection Usage Average"];
            [cellInfo setDetailText:[NSString stringWithFormat:@"%@%%",[connection objectForKey:@"Average"]]];
        }else if([connection isKindOfClass:[NSString class]]){
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Connection-ERROR" andCellReusableId:err_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setDetailText:connection];
            [cellInfo setText:@"Connection Usage Average"];
        }
        [cmsSectionInfo appendCell:cellInfo];
    }
    {
        id iops = [cms objectForKey:@"iops"];
        if([iops isKindOfClass:[NSDictionary class]]){
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"IOPS" andCellReusableId:cms_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setText:@"IOPS Usage Average"];
            [cellInfo setDetailText:[NSString stringWithFormat:@"%@%%",[iops objectForKey:@"Average"]]];
        }else if([iops isKindOfClass:[NSString class]]){
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"IOPS-ERROR" andCellReusableId:err_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setText:@"IOPS Usage Average"];
            [cellInfo setDetailText:iops];
        }
        [cmsSectionInfo appendCell:cellInfo];
    }
    if([_RDSType isEqualToString:@"ReadOnly"]){
        id delay = [cms objectForKey:@"delay"];
        if([delay isKindOfClass:[NSDictionary class]]){
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Delay" andCellReusableId:cms_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setText:@"Data Delay Average"];
            [cellInfo setDetailText:[NSString stringWithFormat:@"%@ s",[delay objectForKey:@"Average"]]];
        }else if([delay isKindOfClass:[NSString class]]){
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Delay-ERROR" andCellReusableId:err_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setText:@"Data Delay Average"];
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

@end
