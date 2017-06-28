//
//  DynamicREDISDetailViewController.m
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/22.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "DynamicREDISDetailViewController.h"
#import "TianwenAPI.h"
#import "TianwenHelper.h"
#import "DynamicProgressTableViewCell.h"

@interface DynamicREDISDetailViewController ()

@end

@implementation DynamicREDISDetailViewController


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
    NSDictionary*dict=[TianwenAPI Product:@"redis" instance:_instanceId inRegion:_regionId forAccount:_account];
    
    [self removeAllSectionInfo];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    
    NSString * error_cell_id=@"DynamicREDISDetailViewController_ErrorCell";
    
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
        NSDictionary * redis=[[dict objectForKey:@"data"]objectForKey:@"redis"];
        NSDictionary*cms=[[dict objectForKey:@"data"]objectForKey:@"cms"];
        
        _navTitle=[NSString stringWithFormat:@"%@",[redis objectForKey:@"instanceId"]];
        
        [self makeSectionFromREDISDictionary:redis];
        [self makeSectionFromCMSDictionary:cms];
    }
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    [self performSelectorOnMainThread:@selector(refreshUI) withObject:nil waitUntilDone:NO];
}

-(void)makeSectionFromREDISDictionary:(NSDictionary*)redis{
    DynamicTableSectionInfo * redisSection=[[DynamicTableSectionInfo alloc]initWithSectionKey:@"REDISSection"];
    [redisSection setTitle:NSLocalizedString(@"REDIS Info",@"")];
    
    DynamicTableCellInfo * cellInfo=nil;
    NSString * normal_cell_id=@"DynamicREDISDetailViewController_NormalCell";
    
    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"instanceId" andCellReusableId:normal_cell_id];
    [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
    [cellInfo setText:NSLocalizedString(@"instanceId",@"")];
    [cellInfo setDetailText:[NSString stringWithFormat:@"%@",[redis objectForKey:@"instanceId"]]];
    [cellInfo setOnSelect:^(DynamicTableCellInfo* _Nonnull cellInfo, id _Nullable otherInfo){
        NSLog(@"in block on select: %@",cellInfo);
    }];
    
    [redisSection appendCell:cellInfo];
    
    [self appendSection:redisSection];
}

-(void)makeSectionFromCMSDictionary:(NSDictionary*)cms{
    DynamicTableSectionInfo * cmsSection=[[DynamicTableSectionInfo alloc]initWithSectionKey:@"CMSSection"];
    [cmsSection setTitle:NSLocalizedString(@"Current Load",@"")];
    
    DynamicTableCellInfo * cellInfo=nil;
    NSString * normal_cell_id=@"DynamicREDISDetailViewController_NormalCell";
    NSString * error_cell_id=@"DynamicREDISDetailViewController_ErrorCell";
    
    {
        id memory=[cms objectForKey:@"memory"];
        if([memory isKindOfClass:[NSDictionary class]]){
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"memory" andCellReusableId:normal_cell_id];
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
            [cmsSection appendCell:cellInfo];
        }else if([memory isKindOfClass:[NSString class]]){
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"memory" andCellReusableId:error_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setText:NSLocalizedString(@"Memory Usage Average",@"")];
            [cellInfo setDetailText:[NSString stringWithFormat:@"%@",memory]];
            [cmsSection appendCell:cellInfo];
        }
    }
    {
        id cpu=[cms objectForKey:@"cpu"];
        if([cpu isKindOfClass:[NSDictionary class]]){
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"cpu" andCellReusableId:normal_cell_id];
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
            [cmsSection appendCell:cellInfo];
        }else if([cpu isKindOfClass:[NSString class]]){
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"cpu" andCellReusableId:error_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setText:NSLocalizedString(@"CPU Usage Average",@"")];
            [cellInfo setDetailText:[NSString stringWithFormat:@"%@",cpu]];
            [cmsSection appendCell:cellInfo];
        }
    }
    {
        id connection=[cms objectForKey:@"connection"];
        if([connection isKindOfClass:[NSDictionary class]]){
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"connection" andCellReusableId:normal_cell_id];
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
            [cmsSection appendCell:cellInfo];
        }else if([connection isKindOfClass:[NSString class]]){
            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"Connection" andCellReusableId:error_cell_id];
            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];
            [cellInfo setText:NSLocalizedString(@"Connection Usage Average",@"")];
            [cellInfo setDetailText:[NSString stringWithFormat:@"%@",connection]];
            [cmsSection appendCell:cellInfo];
        }
    }
    
    [self appendSection:cmsSection];
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
