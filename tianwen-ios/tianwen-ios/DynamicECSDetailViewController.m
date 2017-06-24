//
//  DynamicECSDetailViewController.m
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/22.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "DynamicECSDetailViewController.h"
#import "TianwenAPI.h"
#import "TianwenHelper.h"

@interface DynamicECSDetailViewController ()

@end

@implementation DynamicECSDetailViewController

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
    NSDictionary*dict=[TianwenAPI Product:@"ecs" instance:_instanceId inRegion:_regionId forAccount:_account];
    
    [self removeAllSectionInfo];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    
    if(!dict){
        NSString * sectionKey=@"ErrorSection";
        
        DynamicTableSectionInfo * errorSectionInfo=[[DynamicTableSectionInfo alloc]initWithSectionKey:sectionKey];
        [errorSectionInfo setTitle:sectionKey];
        [self appendSection:errorSectionInfo];
        
        DynamicTableCellInfo * cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Error" andCellReusableId:@"DynamicECSDetailViewController_ErrorCell"];
        [cellInfo setText:@"API Call Failed"];
        [self appendCell:cellInfo toSectionWithKey:sectionKey];
    }else if (![[dict objectForKey:@"code"]isEqualToString:@"OK"]){
        NSString * sectionKey=@"ErrorSection";
        
        DynamicTableSectionInfo * errorSectionInfo=[[DynamicTableSectionInfo alloc]initWithSectionKey:sectionKey];
        [errorSectionInfo setTitle:sectionKey];
        [self appendSection:errorSectionInfo];
        
        DynamicTableCellInfo * cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Error" andCellReusableId:@"DynamicECSDetailViewController_ErrorCell"];
        [cellInfo setText:[NSString stringWithFormat: @"API Error: %@",[dict objectForKey:@"data"]]];
        [self appendCell:cellInfo toSectionWithKey:sectionKey];
    }else{
        NSDictionary * ecs=[[dict objectForKey:@"data"]objectForKey:@"ecs"];
        NSDictionary*cms=[[dict objectForKey:@"data"]objectForKey:@"cms"];
        
        _navTitle=[NSString stringWithFormat:@"%@",[ecs objectForKey:@"InstanceName"]];
        
        [self makeSectionFromECSDictionary:ecs];
        [self makeSectionFromCMSDictionary:cms];
    }
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    [self performSelectorOnMainThread:@selector(refreshUI) withObject:nil waitUntilDone:NO];
}

-(void)makeSectionFromECSDictionary:(NSDictionary*)ecs{
    DynamicTableSectionInfo * ecsSectionInfo=[[DynamicTableSectionInfo alloc]initWithSectionKey:@"ECSSection"];
    [ecsSectionInfo setTitle:@"ECS Info"];
    
    DynamicTableCellInfo*cellInfo=nil;
    NSString * ecs_cell_id=@"DynamicECSDetailViewController_NormalCell";
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"InstanceId" andCellReusableId:ecs_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"InstanceId"];
    [cellInfo setDetailText:[TianwenHelper hiddenForScreenshot:[NSString stringWithFormat:@"%@",[ecs objectForKey:@"InstanceId"]]]];
    [ecsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"InstanceName" andCellReusableId:ecs_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"InstanceName"];
    [cellInfo setDetailText:[TianwenHelper hiddenForScreenshot:[NSString stringWithFormat:@"%@",[ecs objectForKey:@"InstanceName"]]]];
    [ecsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"InnerIpAddress" andCellReusableId:ecs_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"InnerIpAddress"];
    [cellInfo setDetailText:[TianwenHelper hiddenForScreenshot:[NSString stringWithFormat:@"%@",[[ecs objectForKey:@"InnerIpAddress"] componentsJoinedByString:@","]]]];
    [ecsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"PublicIpAddress" andCellReusableId:ecs_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"PublicIpAddress"];
    [cellInfo setDetailText:[TianwenHelper hiddenForScreenshot:[NSString stringWithFormat:@"%@",[[ecs objectForKey:@"PublicIpAddress"] componentsJoinedByString:@","]]]];
    [ecsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"CPU" andCellReusableId:ecs_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"CPU"];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@-Core",[ecs objectForKey:@"Cpu"]]];
    [ecsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Memory" andCellReusableId:ecs_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"Memory"];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@ M",[ecs objectForKey:@"Memory"]]];
    [ecsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"InternetMaxBandwidthOut" andCellReusableId:ecs_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"InternetMaxBandwidthOut"];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@ M",[ecs objectForKey:@"InternetMaxBandwidthOut"]]];
    [ecsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"OS" andCellReusableId:ecs_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"OS"];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@ %@",[ecs objectForKey:@"OSType"],[ecs objectForKey:@"OSName"]]];
    [ecsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"RegionId" andCellReusableId:ecs_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"RegionId"];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[ecs objectForKey:@"RegionId"]]];
    [ecsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"ZoneId" andCellReusableId:ecs_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"ZoneId"];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[ecs objectForKey:@"ZoneId"]]];
    [ecsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Status" andCellReusableId:ecs_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"Status"];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[ecs objectForKey:@"Status"]]];
    [ecsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"OperationLocks" andCellReusableId:ecs_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"OperationLocks"];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[[ecs objectForKey:@"OperationLocks"] componentsJoinedByString:@","]]];
    [ecsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"CreationTime" andCellReusableId:ecs_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"CreationTime"];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[TianwenHelper localizedDateStringFromISO8601String:[ecs objectForKey:@"CreationTime"]]]];
    [ecsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"ExpiredTime" andCellReusableId:ecs_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"ExpiredTime"];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[TianwenHelper localizedDateStringFromISO8601String:[ecs objectForKey:@"ExpiredTime"]]]];
    [ecsSectionInfo appendCell:cellInfo];
    
    [self appendSection:ecsSectionInfo];
}

-(void)makeSectionFromCMSDictionary:(NSDictionary*)cms{
    DynamicTableSectionInfo * cmsSectionInfo=[[DynamicTableSectionInfo alloc]initWithSectionKey:@"CMSSection"];
    [cmsSectionInfo setTitle:@"CPU and Memory"];
    
    DynamicTableCellInfo*cellInfo=nil;
    NSString * cms_cell_id=@"DynamicECSDetailViewController_NormalCell";
    NSString * detailText=@"";
    
    id cpu=[cms objectForKey:@"cpu"];
    if([cpu isKindOfClass:[NSDictionary class]]){
        detailText=[NSString stringWithFormat:@"%@%%",[cpu objectForKey:@"Average"]];
    }else if([cpu isKindOfClass:[NSString class]]){
        detailText=cpu;
    }
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"cpu" andCellReusableId:cms_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"CPU Usage Average"];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",detailText]];
    [cmsSectionInfo appendCell:cellInfo];
    
    id memory=[cms objectForKey:@"memory"];
    if([memory isKindOfClass:[NSDictionary class]]){
        detailText=[NSString stringWithFormat:@"%@%%",[memory objectForKey:@"Average"]];
    }else if([memory isKindOfClass:[NSString class]]){
        detailText=memory;
    }
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"memory" andCellReusableId:cms_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:@"Memory Usage Average"];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",detailText]];
    [cmsSectionInfo appendCell:cellInfo];
    
    [self appendSection:cmsSectionInfo];
    
    DynamicTableSectionInfo * diskSectionInfo=[[DynamicTableSectionInfo alloc]initWithSectionKey:@"DiskSection"];
    [diskSectionInfo setTitle:@"Disk Usage"];
    
    id disk=[cms objectForKey:@"disk"];
    
    if([disk isKindOfClass:[NSDictionary class]]){
        NSArray * list=[disk allValues];
        for(NSUInteger i=0;i<[list count];i++){
            NSDictionary*diskPart=[list objectAtIndex:i];
            
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:[NSString stringWithFormat:@"DISK-%lu",(unsigned long)i] andCellReusableId:cms_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setText:[NSString stringWithFormat:@"%@",[diskPart objectForKey:@"diskname"]]];
            [cellInfo setDetailText:[NSString stringWithFormat:@"%@%%",[diskPart objectForKey:@"Average"]]];
            [diskSectionInfo appendCell:cellInfo];
        }
    }else if([disk isKindOfClass:[NSString class]]){
        cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:[NSString stringWithFormat:@"DISK_ERROR"] andCellReusableId:@"DynamicECSDetailViewController_ErrorCell"];
        [cellInfo setCellStyle:(UITableViewCellStyleDefault)];
        [cellInfo setText:[NSString stringWithFormat:@"%@",disk]];
        [diskSectionInfo appendCell:cellInfo];
    }
    
    [self appendSection:diskSectionInfo];
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
