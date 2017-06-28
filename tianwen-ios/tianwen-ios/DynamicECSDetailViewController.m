//
//  DynamicECSDetailViewController.m
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/22.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "DynamicECSDetailViewController.h"
#import "DynamicProgressTableViewCell.h"

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
        [errorSectionInfo setTitle:NSLocalizedString(@"Failed",@"失败")];
        [self appendSection:errorSectionInfo];
        
        DynamicTableCellInfo * cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Error" andCellReusableId:@"DynamicECSDetailViewController_ErrorCell"];
        [cellInfo setText:NSLocalizedString(@"API Call Failed",@"")];
        [self appendCell:cellInfo toSectionWithKey:sectionKey];
    }else if (![[dict objectForKey:@"code"]isEqualToString:@"OK"]){
        NSString * sectionKey=@"ErrorSection";
        
        DynamicTableSectionInfo * errorSectionInfo=[[DynamicTableSectionInfo alloc]initWithSectionKey:sectionKey];
        [errorSectionInfo setTitle:NSLocalizedString(@"Failed",@"失败")];
        [self appendSection:errorSectionInfo];
        
        DynamicTableCellInfo * cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Error" andCellReusableId:@"DynamicECSDetailViewController_ErrorCell"];
        [cellInfo setText:[NSString stringWithFormat: NSLocalizedString(@"API Error: %@",@""),[dict objectForKey:@"data"]]];
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
    [ecsSectionInfo setTitle:NSLocalizedString(@"ECS Info",@"")];
    
    DynamicTableCellInfo*cellInfo=nil;
    NSString * ecs_cell_id=@"DynamicECSDetailViewController_NormalCell";
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"InstanceId" andCellReusableId:ecs_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"InstanceId",@"")];
    [cellInfo setDetailText:[TianwenHelper hiddenForScreenshot:[NSString stringWithFormat:@"%@",[ecs objectForKey:@"InstanceId"]]]];
    [ecsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"InstanceName" andCellReusableId:ecs_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"InstanceName",@"")];
    [cellInfo setDetailText:[TianwenHelper hiddenForScreenshot:[NSString stringWithFormat:@"%@",[ecs objectForKey:@"InstanceName"]]]];
    [ecsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"InnerIpAddress" andCellReusableId:ecs_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"InnerIpAddress",@"")];
    [cellInfo setDetailText:[TianwenHelper hiddenForScreenshot:[NSString stringWithFormat:@"%@",[[ecs objectForKey:@"InnerIpAddress"] componentsJoinedByString:@","]]]];
    [ecsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"PublicIpAddress" andCellReusableId:ecs_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"PublicIpAddress",@"")];
    [cellInfo setDetailText:[TianwenHelper hiddenForScreenshot:[NSString stringWithFormat:@"%@",[[ecs objectForKey:@"PublicIpAddress"] componentsJoinedByString:@","]]]];
    [ecsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"CPU" andCellReusableId:ecs_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"CPU",@"")];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@-Core",[ecs objectForKey:@"Cpu"]]];
    [ecsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Memory" andCellReusableId:ecs_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"Memory",@"")];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@ M",[ecs objectForKey:@"Memory"]]];
    [ecsSectionInfo appendCell:cellInfo];
    
//    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"InternetMaxBandwidthIn" andCellReusableId:ecs_cell_id];
//    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
//    [cellInfo setText:NSLocalizedString(@"InternetMaxBandwidthIn",@"")];
//    [cellInfo setDetailText:[NSString stringWithFormat:@"%@ M",[ecs objectForKey:@"InternetMaxBandwidthIn"]]];
//    [ecsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"InternetMaxBandwidthOut" andCellReusableId:ecs_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"InternetMaxBandwidthOut",@"")];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@ M",[ecs objectForKey:@"InternetMaxBandwidthOut"]]];
    [ecsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"OS" andCellReusableId:ecs_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"OS",@"")];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@ %@",[ecs objectForKey:@"OSType"],[ecs objectForKey:@"OSName"]]];
    [ecsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"RegionId" andCellReusableId:ecs_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"RegionId",@"")];
    [cellInfo setDetailText:[AliyunAccountModel getDisplayNameForRegionId:[NSString stringWithFormat:@"%@",[ecs objectForKey:@"RegionId"]]]];
    [ecsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"ZoneId" andCellReusableId:ecs_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"ZoneId",@"")];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[ecs objectForKey:@"ZoneId"]]];
    [ecsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Status" andCellReusableId:ecs_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"Status",@"")];
    NSString*ecs_status_string=[NSString stringWithFormat:@"%@",[ecs objectForKey:@"Status"]];
    [cellInfo setDetailText:NSLocalizedString(ecs_status_string, @"")];
    [ecsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"OperationLocks" andCellReusableId:ecs_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"OperationLocks",@"")];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[[ecs objectForKey:@"OperationLocks"] componentsJoinedByString:@","]]];
    [ecsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"CreationTime" andCellReusableId:ecs_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"CreationTime",@"")];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[TianwenHelper localizedDateStringFromISO8601String:[ecs objectForKey:@"CreationTime"]]]];
    [ecsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"ExpiredTime" andCellReusableId:ecs_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"ExpiredTime",@"")];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[TianwenHelper localizedDateStringFromISO8601String:[ecs objectForKey:@"ExpiredTime"]]]];
    [ecsSectionInfo appendCell:cellInfo];
    
    [self appendSection:ecsSectionInfo];
}

-(void)makeSectionFromCMSDictionary:(NSDictionary*)cms{
    DynamicTableSectionInfo * cmsSectionInfo=[[DynamicTableSectionInfo alloc]initWithSectionKey:@"CMSSection"];
    [cmsSectionInfo setTitle:NSLocalizedString(@"Current Load",@"当前负载")];
    
    DynamicTableCellInfo*cellInfo=nil;
    NSString * cms_cell_id=@"DynamicECSDetailViewController_NormalCell";
    NSString * detailText=@"";
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"cpu" andCellReusableId:cms_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"CPU Usage Average",@"CPU 平均负载")];
    id cpu=[cms objectForKey:@"cpu"];
    if([cpu isKindOfClass:[NSDictionary class]]){
        detailText=[NSString stringWithFormat:@"%@%%",[cpu objectForKey:@"Average"]];
        [cellInfo setAdditionCellSettingsBlock:^(__kindof DynamicTableCellInfoCompatibleCell* _Nonnull cell){
            DynamicProgressTableViewCell * dptvc=(DynamicProgressTableViewCell*)cell;
            CGFloat progress=[[NSString stringWithFormat:@"%@",[cpu objectForKey:@"Average"]]floatValue]/100.0;
            NSLog(@"progress: %f",progress);
            UIColor * color=[TianwenHelper colorForProgressRate:progress];
            [dptvc setProgress:progress andColor:color];
        }];
    }else if([cpu isKindOfClass:[NSString class]]){
        detailText=cpu;
    }
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",detailText]];
    [cmsSectionInfo appendCell:cellInfo];
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"memory" andCellReusableId:cms_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"Memory Usage Average",@"内存平均负载")];
    id memory=[cms objectForKey:@"memory"];
    if([memory isKindOfClass:[NSDictionary class]]){
        detailText=[NSString stringWithFormat:@"%@%%",[memory objectForKey:@"Average"]];
        [cellInfo setAdditionCellSettingsBlock:^(__kindof DynamicTableCellInfoCompatibleCell* _Nonnull cell){
            DynamicProgressTableViewCell * dptvc=(DynamicProgressTableViewCell*)cell;
            CGFloat progress=[[NSString stringWithFormat:@"%@",[memory objectForKey:@"Average"]]floatValue]/100.0;
            NSLog(@"progress: %f",progress);
            UIColor * color=[TianwenHelper colorForProgressRate:progress];
            [dptvc setProgress:progress andColor:color];
        }];
    }else if([memory isKindOfClass:[NSString class]]){
        detailText=memory;
    }
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",detailText]];
    [cmsSectionInfo appendCell:cellInfo];
    
    [self appendSection:cmsSectionInfo];
    
    DynamicTableSectionInfo * diskSectionInfo=[[DynamicTableSectionInfo alloc]initWithSectionKey:@"DiskSection"];
    [diskSectionInfo setTitle:NSLocalizedString(@"Disk Usage",@"磁盘用量")];
    
    id disk=[cms objectForKey:@"disk"];
    
    if([disk isKindOfClass:[NSDictionary class]]){
        NSArray * list=[disk allValues];
        for(NSUInteger i=0;i<[list count];i++){
            NSDictionary*diskPart=[list objectAtIndex:i];
            
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:[NSString stringWithFormat:@"DISK-%lu",(unsigned long)i] andCellReusableId:cms_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setText:[NSString stringWithFormat:@"%@",[diskPart objectForKey:@"diskname"]]];
            [cellInfo setDetailText:[NSString stringWithFormat:@"%@%%",[diskPart objectForKey:@"Average"]]];
            [cellInfo setAdditionCellSettingsBlock:^(__kindof DynamicTableCellInfoCompatibleCell* _Nonnull cell){
                DynamicProgressTableViewCell * dptvc=(DynamicProgressTableViewCell*)cell;
                CGFloat progress=[[NSString stringWithFormat:@"%@",[diskPart objectForKey:@"Average"]]floatValue]/100.0;
                NSLog(@"progress: %f",progress);
                UIColor * color=[TianwenHelper colorForProgressRate:progress];
                [dptvc setProgress:progress andColor:color];
            }];
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

-(UITableViewCell *)createReusableCellWithStyle:(UITableViewCellStyle)cellStyle reuseIdentifier:(NSString *)cellReusableId{
    return [[DynamicProgressTableViewCell alloc]initWithStyle:cellStyle reuseIdentifier:cellReusableId];
}

@end
