//
//  RDSDetailViewController.m
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/21.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "RDSDetailViewController.h"
#import "TianwenAPI.h"

@interface RDSDetailViewController ()

@end

@implementation RDSDetailViewController

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
    
    NSDictionary*dict=[TianwenAPI Product:@"rds" instance:_instanceId inRegion:_regionId forAccount:_account];
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
        title=[[_productInfo objectForKey:@"rds"]objectForKey:@"DBInstanceDescription"];
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
    return 1+6;//basic+cpu+memory+disk+connection+iops+delay
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete implementation, return the number of rows
    if(!_productInfo){
        return 1;
    }
    if(section==0){
        return 16;
    }
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RDSDetailCell"];
    if(!cell){
        cell = [[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleValue1) reuseIdentifier:@"RDSDetailCell"];
    }
    
    // Configure the cell...
    
    if(!_productInfo){
        [[cell textLabel]setText:_productError];
        [[cell detailTextLabel]setText:@""];
        
        //[cell setAccessoryView:[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)]];
        
        return cell;
    }
    
    // Configure the cell...
    
    NSString * itemText=@"";
    NSString * detailText=@"";
    
    //default test
    itemText=[NSString stringWithFormat:@"%ld",(long)indexPath.section];
    detailText=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
    
    
    switch (indexPath.section) {
        case 0:
        {
            NSDictionary * rds=[_productInfo objectForKey:@"rds"];
            switch (indexPath.row) {
                case 0:
                {
                    //DBInstanceId
                    itemText=@"DBInstanceId";
                    detailText=[NSString stringWithFormat:@"%@",[rds objectForKey:@"DBInstanceId"]];
                }
                    break;
                case 1:
                {
                    //DBInstanceDescription
                    itemText=@"DBInstanceDescription";
                    detailText=[NSString stringWithFormat:@"%@",[rds objectForKey:@"DBInstanceDescription"]];
                }
                    break;
                case 2:
                {
                    //DBInstanceType
                    itemText=@"DBInstanceType";
                    detailText=[NSString stringWithFormat:@"%@",[rds objectForKey:@"DBInstanceType"]];
                }
                    break;
                case 3:
                {
                    //ConnectionString
                    itemText=@"ConnectionString";
                    detailText=[NSString stringWithFormat:@"%@",[rds objectForKey:@"ConnectionString"]];
                }
                    break;
                case 4:
                {
                    //Port
                    itemText=@"Port";
                    detailText=[NSString stringWithFormat:@"%@",[rds objectForKey:@"Port"]];
                }
                    break;
                case 5:
                {
                    //Engine EngineVersion
                    itemText=@"Engine";
                    detailText=[NSString stringWithFormat:@"%@ %@",[rds objectForKey:@"Port"],[rds objectForKey:@"EngineVersion"]];
                }
                    break;
                case 6:
                {
                    //RegionId
                    itemText=@"RegionId";
                    detailText=[NSString stringWithFormat:@"%@",[rds objectForKey:@"RegionId"]];
                }
                    break;
                case 7:
                {
                    //ZoneId
                    itemText=@"ZoneId";
                    detailText=[NSString stringWithFormat:@"%@",[rds objectForKey:@"ZoneId"]];
                }
                    break;
                case 8:
                {
                    //DBInstanceMemory
                    itemText=@"DBInstanceMemory";
                    detailText=[NSString stringWithFormat:@"%@ M",[rds objectForKey:@"DBInstanceMemory"]];
                }
                    break;
                case 9:
                {
                    //DBInstanceStorage
                    itemText=@"DBInstanceStorage";
                    detailText=[NSString stringWithFormat:@"%@ G",[rds objectForKey:@"DBInstanceStorage"]];
                }
                    break;
                case 10:
                {
                    //MaxIOPS
                    itemText=@"MaxIOPS";
                    detailText=[NSString stringWithFormat:@"%@",[rds objectForKey:@"MaxIOPS"]];
                }
                    break;
                case 11:
                {
                    //MaxConnections
                    itemText=@"MaxConnections";
                    detailText=[NSString stringWithFormat:@"%@",[rds objectForKey:@"MaxConnections"]];
                }
                    break;
                case 12:
                {
                    //MaintainTime
                    itemText=@"MaintainTime";
                    detailText=[NSString stringWithFormat:@"%@",[rds objectForKey:@"MaintainTime"]];
                }
                    break;
                case 13:
                {
                    //AvailabilityValue
                    itemText=@"AvailabilityValue";
                    detailText=[NSString stringWithFormat:@"%@",[rds objectForKey:@"AvailabilityValue"]];
                }
                    break;
                case 14:
                {
                    //CreationTime
                    itemText=@"CreationTime";
                    detailText=[NSString stringWithFormat:@"%@",[rds objectForKey:@"CreationTime"]];
                }
                    break;
                case 15:
                {
                    //ExpireTime
                    itemText=@"ExpireTime";
                    detailText=[NSString stringWithFormat:@"%@",[rds objectForKey:@"ExpireTime"]];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            //cpu
            id cpu = [[_productInfo objectForKey:@"cms"]objectForKey:@"cpu"];
            itemText=@"Average";
            if([cpu isKindOfClass:[NSDictionary class]]){
                detailText=[NSString stringWithFormat:@"%@%%",[cpu objectForKey:@"Average"]];
            }else if([cpu isKindOfClass:[NSString class]]){
                detailText=cpu;
            }
        }
            break;
        case 2:
        {
            //memory
            id memory = [[_productInfo objectForKey:@"cms"]objectForKey:@"memory"];
            itemText=@"Average";
            if([memory isKindOfClass:[NSDictionary class]]){
                detailText=[NSString stringWithFormat:@"%@%%",[memory objectForKey:@"Average"]];
            }else if([memory isKindOfClass:[NSString class]]){
                detailText=memory;
            }
        }
            break;
        case 3:
        {
            //disk
            id disk = [[_productInfo objectForKey:@"cms"]objectForKey:@"disk"];
            itemText=@"Average";
            if([disk isKindOfClass:[NSDictionary class]]){
                detailText=[NSString stringWithFormat:@"%@%%",[disk objectForKey:@"Average"]];
            }else if([disk isKindOfClass:[NSString class]]){
                detailText=disk;
            }
        }
            break;
        case 4:
        {
            //connection
            id connection = [[_productInfo objectForKey:@"cms"]objectForKey:@"connection"];
            itemText=@"Average";
            if([connection isKindOfClass:[NSDictionary class]]){
                detailText=[NSString stringWithFormat:@"%@%%",[connection objectForKey:@"Average"]];
            }else if([connection isKindOfClass:[NSString class]]){
                detailText=connection;
            }
        }
            break;
        case 5:
        {
            //iops
            id iops = [[_productInfo objectForKey:@"cms"]objectForKey:@"iops"];
            itemText=@"Average";
            if([iops isKindOfClass:[NSDictionary class]]){
                detailText=[NSString stringWithFormat:@"%@%%",[iops objectForKey:@"Average"]];
            }else if([iops isKindOfClass:[NSString class]]){
                detailText=iops;
            }
        }
            break;
        case 6:
        {
            //delay
            id delay = [[_productInfo objectForKey:@"cms"]objectForKey:@"delay"];
            itemText=@"Average";
            if([delay isKindOfClass:[NSDictionary class]]){
                detailText=[NSString stringWithFormat:@"%@ s",[delay objectForKey:@"Average"]];
            }else if([delay isKindOfClass:[NSString class]]){
                detailText=delay;
            }
        }
            break;
            
        default:
            break;
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
            return @"RDS Info";
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
        case 4:
            return @"Connection Usage";
            break;
        case 5:
            return @"IOPS Usage";
            break;
        case 6:
            return @"Data Delay";
            break;
        default:
            break;
    }
    return @"...";
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
