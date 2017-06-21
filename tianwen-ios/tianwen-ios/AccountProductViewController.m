//
//  AccountProductViewController.m
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/21.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "AccountProductViewController.h"
#import "TianwenAPI.h"

#import "ECSDetailViewController.h"
#import "RDSDetailViewController.h"
#import "REDISDetailViewController.h"

@interface AccountProductViewController ()

@end

@implementation AccountProductViewController

-(instancetype)initWithStyle:(UITableViewStyle)style{
    self=[super initWithStyle:style];
    if(self){
        _accounts=[[AliyunAccountModel storedAccounts]allValues];
        _productsByAccount=[@[] mutableCopy];
        for (NSUInteger i=0; i<[_accounts count]; i++) {
            [_productsByAccount addObject:@{
                                             @"error":@"Loading",
                                             }
             ];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title=@"Products";
    
    for (NSUInteger i=0; i<[_accounts count]; i++) {
        [self performSelectorInBackground:@selector(loadProductListDataInBackground:) withObject:@(i)];
    }
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadProductListDataInBackground:(NSNumber*)index{
    AliyunAccountModel * account=[_accounts objectAtIndex:[index unsignedIntegerValue]];
    NSDictionary*result=[TianwenAPI ProductList:@"all" forAccount:account];
    if(!result){
        [_productsByAccount replaceObjectAtIndex:[index unsignedIntegerValue]
                                      withObject:@{
                                                   @"error":@"Load Failed"
                                                   }
         ];
    }else{
        if(![[result objectForKey:@"code"]isEqualToString:@"OK"]){
            NSString * error=[result objectForKey:@"data"];
            if(!error)error=@"Unknown Error";
        }else{
            NSDictionary*group=[result objectForKey:@"data"];
            NSArray * groupECS=[group objectForKey:@"ECS"];
            NSArray * groupRDS=[group objectForKey:@"RDS"];
            NSArray * groupREDIS=[group objectForKey:@"REDIS"];
            
            NSMutableArray * productList=[@[] mutableCopy];
            for (NSUInteger item_id=0;item_id < [groupECS count];item_id++) {
                NSMutableDictionary*product=[[groupECS objectAtIndex:item_id] mutableCopy];
                [product setObject:@"ECS" forKey:@"_PRODUCT_TYPE"];
                [product setObject:[product objectForKey:@"InstanceName"] forKey:@"_PRODUCT_NAME"];
                [productList addObject:product];
            }
            for (NSUInteger item_id=0;item_id < [groupRDS count];item_id++) {
                NSMutableDictionary*product=[[groupRDS objectAtIndex:item_id] mutableCopy];
                [product setObject:@"RDS" forKey:@"_PRODUCT_TYPE"];
                [product setObject:[product objectForKey:@"DBInstanceDescription"] forKey:@"_PRODUCT_NAME"];
                [productList addObject:product];
            }
            for (NSUInteger item_id=0;item_id < [groupREDIS count];item_id++) {
                NSMutableDictionary*product=[[groupREDIS objectAtIndex:item_id] mutableCopy];
                [product setObject:@"REDIS" forKey:@"_PRODUCT_TYPE"];
                [product setObject:[product objectForKey:@"instanceId"] forKey:@"_PRODUCT_NAME"];
                [productList addObject:product];
            }
            
            [_productsByAccount replaceObjectAtIndex:[index unsignedIntegerValue]
                                          withObject:@{
                                                       @"products":productList
                                                       }
             ];
        }
    }
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_accounts count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(
       [_productsByAccount objectAtIndex:section]
       && [[_productsByAccount objectAtIndex:section] objectForKey:@"products"]
       ){
        return [[[_productsByAccount objectAtIndex:section] objectForKey:@"products"] count];
    }
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AccountProductViewControllerCell"];
    if(!cell){
        cell=[[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleValue1) reuseIdentifier:@"AccountProductViewControllerCell"];
    }
    
    // Configure the cell...
    NSDictionary*dict=[_productsByAccount objectAtIndex:indexPath.section];
    if([dict objectForKey:@"error"]){
        [[cell textLabel]setText:[dict objectForKey:@"error"]];
        [[cell detailTextLabel]setText:@""];
        UIImage*image=[UIImage imageNamed:@"OTHER ISSUE"];
        [[cell imageView]setImage:image];
        [cell setAccessoryType:(UITableViewCellAccessoryNone)];
    }else{
        NSDictionary*item=[[dict objectForKey:@"products"] objectAtIndex:indexPath.row];
        [[cell textLabel]setText:[item objectForKey:@"_PRODUCT_NAME"]];
        [[cell detailTextLabel]setText:[item objectForKey:@"_PRODUCT_TYPE"]];
        
        UIImage * image=[UIImage imageNamed:[item objectForKey:@"_PRODUCT_TYPE"]];
        if(!image){
            image=[UIImage imageNamed:@"OTHER ISSUE"];
        }
        [[cell imageView]setImage:image];
        
        [cell setAccessoryType:(UITableViewCellAccessoryDisclosureIndicator)];
    }
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    AliyunAccountModel * account=[_accounts objectAtIndex:section];
    return [account nickname];
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary*dict=[_productsByAccount objectAtIndex:indexPath.section];
    if([dict objectForKey:@"error"]){
        return;
    }else{
        NSDictionary*item=[[dict objectForKey:@"products"] objectAtIndex:indexPath.row];
        
        NSString*product_type=[item objectForKey:@"_PRODUCT_TYPE"];
        if([product_type isEqualToString:@"ECS"]){
            ECSDetailViewController*ecsVC=[[ECSDetailViewController alloc]initWithInstanceId:[item objectForKey:@"InstanceId"] andRegionId:[item objectForKey:@"RegionId"] forAccount:[_accounts objectAtIndex:indexPath.section]];
            
            [[self navigationController]pushViewController:ecsVC animated:YES];
        }else if([product_type isEqualToString:@"RDS"]){
            RDSDetailViewController*rdsVC=[[RDSDetailViewController alloc]initWithInstanceId:[item objectForKey:@"DBInstanceId"] andRegionId:[item objectForKey:@"RegionId"] forAccount:[_accounts objectAtIndex:indexPath.section]];
            
            [[self navigationController]pushViewController:rdsVC animated:YES];
        }else if([product_type isEqualToString:@"REDIS"]){
            REDISDetailViewController*redisVC=[[REDISDetailViewController alloc]initWithInstanceId:[item objectForKey:@"instanceId"] andRegionId:[item objectForKey:@"RegionId"] forAccount:[_accounts objectAtIndex:indexPath.section]];
            [[self navigationController]pushViewController:redisVC animated:YES];
        }
    }
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