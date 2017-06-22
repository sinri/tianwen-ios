//
//  DynamicTableViewController.m
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/22.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "DynamicTableViewController.h"

@interface DynamicTableViewController ()

@end

@implementation DynamicTableViewController

-(instancetype)initWithStyle:(UITableViewStyle)style{
    self=[super initWithStyle:style];
    if(self){
        _sections=[@[] mutableCopy];
    }
    return self;
}

-(void)demo{
    _sections=[@[] mutableCopy];
    
    [self.tableView reloadData];
}

-(BOOL)appendCell:(DynamicTableCellInfo*)cellInfo toSectionWithKey:(NSString*)sectionKey{
    DynamicTableSectionInfo*sectionInfo=[self getSectionInfoWithKey:sectionKey];
    if(!sectionInfo)return NO;
    return [sectionInfo appendCell:cellInfo];
}

-(BOOL)appendSection:(DynamicTableSectionInfo*)sectionInfo{
    NSString*sectionKey=[sectionInfo sectionKey];
    if(!sectionKey)return NO;
    
    for(NSUInteger i=0;i<[_sections count];i++){
        if([[[_sections objectAtIndex:i]sectionKey]isEqualToString:sectionKey]){
            return NO;
        }
    }
    
    [_sections addObject:sectionInfo];
    
    return YES;
}

-(DynamicTableSectionInfo*)getSectionInfoWithKey:(NSString*)sectionKey{
    for(NSUInteger i=0;i<[_sections count];i++){
        if([[[_sections objectAtIndex:i]sectionKey]isEqualToString:sectionKey]){
            return [_sections objectAtIndex:i];
        }
    }
    return nil;
}

-(BOOL)removeSectionWithKey:(NSString*_Nonnull)sectionKey{
    NSInteger target_index=-1;
    for(NSUInteger i=0;i<[_sections count];i++){
        if([[[_sections objectAtIndex:i]sectionKey]isEqualToString:sectionKey]){
            target_index=i;
            break;
        }
    }
    if(target_index<0)return NO;
    [_sections removeObjectAtIndex:target_index];
    return YES;
}

-(void)removeAllSectionInfo{
    [_sections removeAllObjects];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return [_sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    return [[[_sections objectAtIndex:section]cells]count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DynamicTableCellInfo*cellInfo=[[[_sections objectAtIndex:indexPath.section]cells]objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[cellInfo cellReusableId]];
    if(!cell){
        cell = [[UITableViewCell alloc]initWithStyle:[cellInfo cellStyle] reuseIdentifier:[cellInfo cellReusableId]];
    }
    
    // Configure the cell...
    if([cellInfo text]){
        [[cell textLabel]setText:[cellInfo text]];
    }
    if([cellInfo detailText]){
        [[cell detailTextLabel]setText:[cellInfo detailText]];
    }
    if([cellInfo imageName]){
        [[cell imageView]setImage:[UIImage imageNamed:[cellInfo imageName]]];
    }
    
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
    DynamicTableSectionInfo*sectionInfo=[_sections objectAtIndex:section];
    if([sectionInfo title]){
        return [sectionInfo title];
    }
    return nil;
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
