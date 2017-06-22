//
//  ECSDetailViewController.m
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/21.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "ECSDetailViewController.h"
#import "TianwenAPI.h"

@interface ECSDetailViewController ()

@end

@implementation ECSDetailViewController

-(instancetype)initWithInstanceId:(NSString *)instanceId andRegionId:(NSString *)regionId forAccount:(AliyunAccountModel *)account{
    self = [super initWithStyle:(UITableViewStyleGrouped)];
    if(self){
        _account=account;
        _regionId=regionId;
        _instanceId=instanceId;
        
        _productInfo=nil;
        _productError=@"Loading";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title=[NSString stringWithFormat:@"Loading %@",_instanceId];
    
    UIActivityIndicatorView*aiv=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    [aiv startAnimating];
    UIBarButtonItem * refreshButton=[[UIBarButtonItem alloc]initWithCustomView:aiv];
    [self.navigationItem setRightBarButtonItem:refreshButton];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self performSelectorInBackground:@selector(loadDataInBackground) withObject:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadDataInBackground{
    _productInfo=nil;
    _productError=@"Loading";
    
    NSDictionary*dict=[TianwenAPI Product:@"ecs" instance:_instanceId inRegion:_regionId forAccount:_account];
    if(!dict){
        _productError=@"API Call Failed";
    }else if (![[dict objectForKey:@"code"]isEqualToString:@"OK"]){
        _productError=[NSString stringWithFormat: @"API Error: %@",[dict objectForKey:@"data"]];
    }else{
        _productInfo=[dict objectForKey:@"data"];
        _productError=@"No Error";
    }
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    [self performSelectorOnMainThread:@selector(refreshUI) withObject:nil waitUntilDone:NO];
}

-(void)refreshUI{
    NSString*title=[NSString stringWithFormat:@"%@",_instanceId];
    if(_productInfo){
        title=[[_productInfo objectForKey:@"ecs"]objectForKey:@"InstanceName"];
    }
    [self.navigationItem setTitle:title];
    
    UIBarButtonItem * refreshButton=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:(UIBarButtonSystemItemRefresh) target:self action:@selector(onRefreshButton:)];
    [self.navigationItem setRightBarButtonItem:refreshButton];
}

-(void)onRefreshButton:(id)sender{
    UIActivityIndicatorView*aiv=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    [aiv startAnimating];
    UIBarButtonItem * refreshButton=[[UIBarButtonItem alloc]initWithCustomView:aiv];
    [self.navigationItem setRightBarButtonItem:refreshButton];
    
    [self performSelectorInBackground:@selector(loadDataInBackground) withObject:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Incomplete implementation, return the number of sections
    if(!_productInfo){
        return 1;
    }
    return 1+3;//basic+cpu+memory+disk
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete implementation, return the number of rows
    if(!_productInfo){
        return 1;
    }
    if(section==0){
        return 14;
    }else if(section==1){
        return 1;
    }else if(section==2){
        return 1;
    }else if(section==3){
        id disk=[[_productInfo objectForKey:@"cms"]objectForKey:@"disk"];
        if([disk isKindOfClass:[NSArray class]]){
            return [disk count];
        }else{
            return 1;
        }
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ECSDetailCell"];
    if(!cell){
        cell = [[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleValue1) reuseIdentifier:@"ECSDetailCell"];
    }
    
    // Configure the cell...
    
    if(!_productInfo){
        [[cell textLabel]setText:_productError];
        [[cell detailTextLabel]setText:@""];
        
        //[cell setAccessoryView:[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)]];
        
        return cell;
    }
    
    //[cell setAccessoryView:nil];
    
    NSString * itemText=@"";
    NSString * detailText=@"";
    
    //default test
    itemText=[NSString stringWithFormat:@"%ld",(long)indexPath.section];
    detailText=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
    
    if(indexPath.section==0){
        NSDictionary * ecs=[_productInfo objectForKey:@"ecs"];
        switch (indexPath.row) {
            case 0:
            {
                //InstanceId
                itemText=@"InstanceId";
                detailText=[ecs objectForKey:@"InstanceId"];
            }
                break;
            case 1:
            {
                //InstanceName
                itemText=@"InstanceName";
                detailText=[ecs objectForKey:@"InstanceName"];
            }
                break;
            case 2:
            {
                //InnerIpAddress
                itemText=@"InnerIpAddress";
                NSArray*ips=[ecs objectForKey:@"InnerIpAddress"];
                detailText=[ips componentsJoinedByString:@","];
            }
                break;
            case 3:
            {
                //PublicIpAddress
                itemText=@"PublicIpAddress";
                NSArray*ips=[ecs objectForKey:@"PublicIpAddress"];
                detailText=[ips componentsJoinedByString:@","];
            }
                break;
            case 4:
            {
                //Cpu
                itemText=@"CPU";
                detailText=[NSString stringWithFormat:@"%@-Core",[ecs objectForKey:@"Cpu"]];
            }
                break;
            case 5:
            {
                //Memory
                itemText=@"Memory";
                detailText=[NSString stringWithFormat:@"%@ M",[ecs objectForKey:@"Memory"]];
            }
                break;
            case 6:
            {
                //InternetMaxBandwidthOut
                itemText=@"InternetMaxBandwidthOut";
                detailText=[NSString stringWithFormat:@"%@ M",[ecs objectForKey:@"InternetMaxBandwidthOut"]];
            }
                break;
            case 7:
            {
                //OSType OSName
                itemText=@"OS";
                detailText=[NSString stringWithFormat:@"%@ %@",[ecs objectForKey:@"OSType"],[ecs objectForKey:@"OSName"]];
            }
                break;
            case 8:
            {
                //RegionId
                itemText=@"RegionId";
                detailText=[ecs objectForKey:@"RegionId"];
                
            }
                break;
            case 9:
            {
                //RegionId
                itemText=@"ZoneId";
                detailText=[ecs objectForKey:@"ZoneId"];
                
            }
                break;
            case 10:
            {
                //Status
                itemText=@"Status";
                detailText=[ecs objectForKey:@"Status"];
                
            }
                break;
            case 11:
            {
                //OperationLocks
                itemText=@"OperationLocks";
                NSArray*ips=[ecs objectForKey:@"OperationLocks"];
                detailText=[ips componentsJoinedByString:@","];
            }
                break;
            case 12:
            {
                //CreationTime
                itemText=@"CreationTime";
                detailText=[ecs objectForKey:@"CreationTime"];
                
            }
                break;
            case 13:
            {
                //ExpiredTime
                itemText=@"ExpiredTime";
                detailText=[ecs objectForKey:@"ExpiredTime"];
                
            }
                break;
            default:
                
                break;
        }
    }else if(indexPath.section==1){
        NSDictionary * cms=[_productInfo objectForKey:@"cms"];
        id cpu=[cms objectForKey:@"cpu"];
        itemText=@"Average";
        if([cpu isKindOfClass:[NSDictionary class]]){
            detailText=[NSString stringWithFormat:@"%@%%",[cpu objectForKey:@"Average"]];
        }else if([cpu isKindOfClass:[NSString class]]){
            detailText=cpu;
        }
    }else if(indexPath.section==2){
        NSDictionary * cms=[_productInfo objectForKey:@"cms"];
        id memory=[cms objectForKey:@"memory"];
        itemText=@"Average";
        if([memory isKindOfClass:[NSDictionary class]]){
            detailText=[NSString stringWithFormat:@"%@%%",[memory objectForKey:@"Average"]];
        }else if([memory isKindOfClass:[NSString class]]){
            detailText=memory;
        }
    }else if(indexPath.section==3){
        NSDictionary * cms=[_productInfo objectForKey:@"cms"];
        id disk=[[cms objectForKey:@"disk"]allValues];
        if([disk isKindOfClass:[NSArray class]]){
            NSDictionary*diskPart=[disk objectAtIndex:indexPath.row];
            itemText=[diskPart objectForKey:@"diskname"];
            detailText=[NSString stringWithFormat:@"%@%%",[diskPart objectForKey:@"Average"]];
        }else{
            itemText=disk;
            detailText=@"";
        }
    }
    
    [[cell textLabel]setText:itemText];
    [[cell detailTextLabel]setText:detailText];
    
    return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"ECS Info";
            break;
        case 1:
            return @"CPU Usage";
            break;
        case 2:
            return @"Memory Usage";
            break;
        case 3:
            return @"Disk Usage";
            break;
        default:
            break;
    }
    return @"";
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

/*
 InnerIpAddress : array of string
 PublicIpAddress : array of string
 
 InstanceId : string
 InstanceName : string
 
 ZoneId : string
 InternetChargeType : string
 IoOptimized: bool
 Memory : int
 Cpu : int
 InternetMaxBandwidthOut : int
 DeviceAvailable : bool
 SecurityGroupIds: array of string
 
 CreationTime :  ISO8601 Datetime
 ExpiredTime : ISO8601 Datetime
 Description : string
 OSType : string
 OSName : string
 InstanceNetworkType : string
 Status : string
 RegionId : string
 OperationLocks : array of ?
 
 */
