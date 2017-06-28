//
//  DynamicSLBDetailViewController.m
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/28.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "DynamicSLBDetailViewController.h"

#import "TianwenAPI.h"
#import "TianwenHelper.h"
#import "DynamicProgressTableViewCell.h"

#import "DynamicECSDetailViewController.h"


@interface DynamicSLBDetailViewController ()

@end

@implementation DynamicSLBDetailViewController

-(instancetype)initWithInstanceId:(NSString *)instanceId andRegionId:(NSString *)regionId forAccount:(AliyunAccountModel *)account{
    self=[super initWithStyle:(UITableViewStyleGrouped)];
    if(self){
        _instanceId=instanceId;
        _regionId=regionId;
        _account=account;
        _navTitle=_instanceId;
        
        //NSLog(@"DynamicREDISDetailViewController init %@ %@",_instanceId,_regionId);
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
    NSDictionary*dict=[TianwenAPI Product:@"slb" instance:_instanceId inRegion:_regionId forAccount:_account];
    
    [self removeAllSectionInfo];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    
    NSString * error_cell_id=@"DynamicSLBDetailViewController_ErrorCell";
    
    //NSLog(@"DynamicREDISDetailViewController called: %@",dict);
    
    if(!dict){
        NSString * sectionKey=@"ErrorSection";
        
        DynamicTableSectionInfo * errorSectionInfo=[[DynamicTableSectionInfo alloc]initWithSectionKey:sectionKey];
        [errorSectionInfo setTitle:NSLocalizedString(@"Failed",@"失败")];
        [self appendSection:errorSectionInfo];
        
        DynamicTableCellInfo * cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Error" andCellReusableId:error_cell_id];
        [cellInfo setText:NSLocalizedString(@"API Call Failed",@"")];
        [self appendCell:cellInfo toSectionWithKey:sectionKey];
    }else if (![[dict objectForKey:@"code"]isEqualToString:@"OK"]){
        NSString * sectionKey=@"ErrorSection";
        
        DynamicTableSectionInfo * errorSectionInfo=[[DynamicTableSectionInfo alloc]initWithSectionKey:sectionKey];
        [errorSectionInfo setTitle:NSLocalizedString(@"Failed",@"失败")];
        [self appendSection:errorSectionInfo];
        
        DynamicTableCellInfo * cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Error" andCellReusableId:error_cell_id];
        [cellInfo setText:[NSString stringWithFormat: NSLocalizedString(@"API Error: %@",@""),[dict objectForKey:@"data"]]];
        [self appendCell:cellInfo toSectionWithKey:sectionKey];
    }else{
        NSDictionary * slb=[[dict objectForKey:@"data"]objectForKey:@"slb"];
        NSDictionary*cms=[[dict objectForKey:@"data"]objectForKey:@"cms"];
        
        _navTitle=[NSString stringWithFormat:@"%@",[slb objectForKey:@"LoadBalancerName"]];
        
        [self makeSectionFromSLBDictionary:slb];
        [self makeSectionFromCMSDictionary:cms];
    }
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    [self performSelectorOnMainThread:@selector(refreshUI) withObject:nil waitUntilDone:NO];
}
-(void)makeSectionFromSLBDictionary:(NSDictionary*)slb{
    DynamicTableSectionInfo * slbSection=[[DynamicTableSectionInfo alloc]initWithSectionKey:@"SLBSection"];
    [slbSection setTitle:NSLocalizedString(@"SLB Info",@"")];
    
    DynamicTableCellInfo * cellInfo=nil;
    NSString * normal_cell_id=@"DynamicSLBDetailViewController_NormalCell";
    NSString * error_cell_id=@"DynamicSLBDetailViewController_ErrorCell";
    
    {
        cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"LoadBalancerId" andCellReusableId:normal_cell_id];
        [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
        [cellInfo setText:NSLocalizedString(@"LoadBalancerId", @"")];
        [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[slb objectForKey:@"LoadBalancerId"]]];
        
        [slbSection appendCell:cellInfo];
    }
    {
        cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"LoadBalancerName" andCellReusableId:normal_cell_id];
        [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
        [cellInfo setText:NSLocalizedString(@"LoadBalancerName", @"")];
        [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[slb objectForKey:@"LoadBalancerName"]]];
        
        [slbSection appendCell:cellInfo];
    }
    {
        NSString*nettype=[NSString stringWithFormat:@"%@",[slb objectForKey:@"NetworkType"]];
        
        cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"NetworkType" andCellReusableId:normal_cell_id];
        [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
        [cellInfo setText:NSLocalizedString(@"NetworkType", @"")];
        [cellInfo setDetailText:NSLocalizedString(nettype, @"")];
        
        [slbSection appendCell:cellInfo];
    }
    {
        cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Address" andCellReusableId:normal_cell_id];
        [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
        [cellInfo setText:NSLocalizedString(@"IP Address", @"")];
        [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[slb objectForKey:@"Address"]]];
        
        [slbSection appendCell:cellInfo];
    }
    {
        NSString*nettype=[NSString stringWithFormat:@"%@",[slb objectForKey:@"AddressType"]];
        
        cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"AddressType" andCellReusableId:normal_cell_id];
        [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
        [cellInfo setText:NSLocalizedString(@"AddressType", @"")];
        [cellInfo setDetailText:NSLocalizedString(nettype, @"")];
        
        [slbSection appendCell:cellInfo];
    }
    {
        cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Bandwidth" andCellReusableId:normal_cell_id];
        [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
        [cellInfo setText:NSLocalizedString(@"Bandwidth", @"")];
        [cellInfo setDetailText:[NSString stringWithFormat:@"%@ M",[slb objectForKey:@"Bandwidth"]]];
        
        [slbSection appendCell:cellInfo];
    }
    {
        NSString*nettype=[NSString stringWithFormat:@"%@",[slb objectForKey:@"LoadBalancerStatus"]];
        
        cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"LoadBalancerStatus" andCellReusableId:normal_cell_id];
        [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
        [cellInfo setText:NSLocalizedString(@"LoadBalancerStatus", @"")];
        [cellInfo setDetailText:NSLocalizedString(nettype, @"")];
        
        [slbSection appendCell:cellInfo];
    }
    {
        NSString*nettype=[NSString stringWithFormat:@"%@",[slb objectForKey:@"RegionIdAlias"]];
        
        cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"RegionIdAlias" andCellReusableId:normal_cell_id];
        [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
        [cellInfo setText:NSLocalizedString(@"RegionId", @"")];
        [cellInfo setDetailText:[AliyunAccountModel getDisplayNameForRegionId:nettype]];
        
        [slbSection appendCell:cellInfo];
    }
    {
        cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"MasterZoneId" andCellReusableId:normal_cell_id];
        [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
        [cellInfo setText:NSLocalizedString(@"MasterZoneId", @"")];
        [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[slb objectForKey:@"MasterZoneId"]]];
        
        [slbSection appendCell:cellInfo];
    }
    {
        cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"SlaveZoneId" andCellReusableId:normal_cell_id];
        [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
        [cellInfo setText:NSLocalizedString(@"SlaveZoneId", @"")];
        [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[slb objectForKey:@"SlaveZoneId"]]];
        
        [slbSection appendCell:cellInfo];
    }
    {
        cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"CreateTime" andCellReusableId:normal_cell_id];
        [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
        [cellInfo setText:NSLocalizedString(@"CreateTime", @"")];
        [cellInfo setDetailText:[TianwenHelper localizedDateStringFromISO8601String:[NSString stringWithFormat:@"%@",[slb objectForKey:@"CreateTime"]]]];
        
        [slbSection appendCell:cellInfo];
    }
    
    [self appendSection:slbSection];
    
    //listeners
    DynamicTableSectionInfo * listenSection=[[DynamicTableSectionInfo alloc]initWithSectionKey:@"ListenerPortsAndProtocol"];
    [listenSection setTitle:NSLocalizedString(@"Listen Configuration", @"监听配置")];
    
    if([slb objectForKey:@"ListenerPortsAndProtocol"]
       && (
       [[slb objectForKey:@"ListenerPortsAndProtocol"] isKindOfClass:[NSNull class]]
           || [[[slb objectForKey:@"ListenerPortsAndProtocol"] allKeys]count]<=0
           )
       ){
        cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"NO_LISTENER" andCellReusableId:error_cell_id];
        [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
        [cellInfo setText:NSLocalizedString(@"Listener Not Configured", @"未设置监听")];
        [cellInfo setDetailText:nil];
        
        [listenSection appendCell:cellInfo];
    }else{
        for (NSString*port in [slb objectForKey:@"ListenerPortsAndProtocol"]) {
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:port andCellReusableId:normal_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setText:[NSString stringWithFormat:@"%@ (%@)",port,[[slb objectForKey:@"ListenerPortsAndProtocol"] objectForKey:port]]];
            [cellInfo setDetailText:@"..."];
            
            [listenSection appendCell:cellInfo];
        }
    }
    
    [self appendSection:listenSection];
    
    DynamicTableSectionInfo * serverSection=[[DynamicTableSectionInfo alloc]initWithSectionKey:@"BackendServers"];
    [serverSection setTitle:NSLocalizedString(@"Backend Servers", @"后端服务器")];
    
    if([slb objectForKey:@"BackendServers"]
       && (
           [[slb objectForKey:@"BackendServers"] isKindOfClass:[NSNull class]]
           || [[[slb objectForKey:@"BackendServers"] allKeys]count]<=0
           )
       ){
        cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"NO_SERVER" andCellReusableId:error_cell_id];
        [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
        [cellInfo setText:NSLocalizedString(@"No Backend Servers", @"无后端服务器")];
        [cellInfo setDetailText:nil];
        
        [serverSection appendCell:cellInfo];
    }else{
        for (NSString*server_id in [slb objectForKey:@"BackendServers"]) {
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:server_id andCellReusableId:normal_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setText:server_id];
            [cellInfo setDetailText:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Weight", @"权重"),[[slb objectForKey:@"BackendServers"] objectForKey:server_id]]];
            [cellInfo setCellAccessoryType:(UITableViewCellAccessoryDisclosureIndicator)];
            
            __weak DynamicSLBDetailViewController * weakSelf=self;
            
            [cellInfo setOnSelect:^(DynamicTableCellInfo* _Nonnull cellInfo, id _Nullable otherInfo){
                DynamicECSDetailViewController*ecsVC=[[DynamicECSDetailViewController alloc]initWithInstanceId:server_id andRegionId:_regionId forAccount:_account];
                [[weakSelf navigationController]pushViewController:ecsVC animated:YES];
            }];
            
            [serverSection appendCell:cellInfo];
        }
    }

    [self appendSection:serverSection];
    
    //NSLog(@"makeSectionFromSLBDictionary: %@",slb);
}
-(void)makeSectionFromCMSDictionary:(NSDictionary*)cms{
    DynamicTableSectionInfo * cmsSection=[[DynamicTableSectionInfo alloc]initWithSectionKey:@"CMSSection"];
    [cmsSection setTitle:NSLocalizedString(@"Current Load",@"")];
    
    DynamicTableCellInfo * cellInfo=nil;
    NSString * normal_cell_id=@"DynamicSLBDetailViewController_NormalCell";
    NSString * error_cell_id=@"DynamicSLBDetailViewController_ErrorCell";
    
    DynamicTableSectionInfo * listenSection=[self getSectionInfoWithKey:@"ListenerPortsAndProtocol"];
    
    NSDictionary * ServerHealthStat=[cms objectForKey:@"ServerHealthStat"];
    
    for (NSString * port in ServerHealthStat) {
        cellInfo=[listenSection getCellInfoWithKey:port];
        CGFloat healthy=[[[ServerHealthStat objectForKey:port]objectForKey:@"healthy"]floatValue];
        CGFloat unhealthy=[[[ServerHealthStat objectForKey:port]objectForKey:@"unhealthy"]floatValue];
        if(healthy+unhealthy>0){
            [cellInfo setAdditionCellSettingsBlock:^(__kindof DynamicTableCellInfoCompatibleCell* _Nonnull cell){
                DynamicProgressTableViewCell * dptvc=(DynamicProgressTableViewCell*)cell;
                CGFloat progress=(healthy)/(healthy+unhealthy);
                NSLog(@"progress: %f",progress);
                UIColor * color=[TianwenHelper colorForProgressRate:(1.0-progress)];
                [dptvc setProgress:progress andColor:color];
            }];
            [cellInfo setDetailText:[NSString stringWithFormat:@"%.2f%% %@", (healthy)/(healthy+unhealthy)*100.0,NSLocalizedString(@"Available", @"可用")]];
        }else{
            //
        }
        
    }
    
    NSLog(@"makeSectionFromCMSDictionary: %@",cms);
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
