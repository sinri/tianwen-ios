//
//  DynamicTianwenWarningView.m
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/22.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "DynamicTianwenWarningView.h"
#import "TianwenAPI.h"

#import "DynamicECSDetailViewController.h"
#import "DynamicRDSDetailViewController.h"
#import "DynamicREDISDetailViewController.h"

@implementation DynamicTianwenWarningView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self){
        _sections=[@[] mutableCopy];
        
        _warningTable=[[UITableView alloc]initWithFrame:(CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)) style:(UITableViewStyleGrouped)];
        [_warningTable setDelegate:self];
        [_warningTable setDataSource:self];
        [self addSubview:_warningTable];
        
        __weak UITableView * weakTable=_warningTable;
        __weak DynamicTianwenWarningView * weakSelf=self;
        
        weakTable.mj_header=[MJRefreshNormalHeader headerWithRefreshingBlock:^{
            //            if(weakTable.mj_header.isRefreshing){
            //                NSLog(@"上一轮刷新还没有结束。。。");
            //                return;
            //            }
            
            NSLog(@"刷新开始");
            
            // loading
            
            if([weakSelf delegate] && [[weakSelf delegate] respondsToSelector:@selector(reloadAccountsForDynamicTianwenWarningView:)]){
                [weakSelf setAccounts:[[weakSelf delegate]reloadAccountsForDynamicTianwenWarningView:weakSelf]];
                NSLog(@"reload accounts from delegate: %@",[weakSelf accounts]);
            }
            
            [weakSelf loadDataForAccounts:_accounts];
            
            // 结束刷新
            [weakTable.mj_header endRefreshing];
            
            NSLog(@"刷新结束");
        }];
        // 设置自动切换透明度(在导航栏下面自动隐藏)
        weakTable.mj_header.automaticallyChangeAlpha = YES;
    }
    return self;
}

-(void)loadDataForAccounts:(NSArray<AliyunAccountModel *> *)accounts{
    NSLog(@"accounts: %@",accounts);
    _accounts=accounts;
    
    _sections=[@[] mutableCopy];
    [_warningTable reloadData];
    
    for(NSUInteger i=0;i<[accounts count];i++){
        AliyunAccountModel *account=[accounts objectAtIndex:i];
        DynamicTableSectionInfo * sectionInfo=[[DynamicTableSectionInfo alloc]initWithSectionKey:[account computeAliyunAccountModelKey]];
        [sectionInfo setTitle:[account nickname]];
        
            DynamicTableCellInfo * cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"LoadingCell" andCellReusableId:@"LoadingCell"];
            [cellInfo setText:@"Loading"];
            [cellInfo setImageName:@"LOADING"];
            
            [sectionInfo appendCell:cellInfo];
        
        [_sections addObject:sectionInfo];
    }
    
    for(NSUInteger i=0;i<[accounts count];i++){
        [self performSelectorInBackground:@selector(loadWarningInfoInBackgroundForAccount:) withObject:[accounts objectAtIndex:i]];
    }
}

-(void)loadWarningInfoInBackgroundForAccount:(AliyunAccountModel*)account{
    NSDictionary*dict=nil;
    if([account isAKMode]){
        dict=[TianwenAPI CloudAssetsDoctor:@"common" forAccount:account];
    }else if ([account isUPMode]){
        dict=[TianwenAPI CloudAssetsDoctor:@"commonWithCache" forAccount:account];
    }else{
        dict=nil;//@{@"code":@"FAIL",@"data":@"Account has mistake so cannot call API."};
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshUIByDictionary:dict forAccount:account];
    });
}

-(void)refreshUIByDictionary:(NSDictionary*)dict forAccount:(AliyunAccountModel*)account{
    DynamicTableSectionInfo * sectionInfo=[[DynamicTableSectionInfo alloc]initWithSectionKey:[account computeAliyunAccountModelKey]];
    [sectionInfo setTitle:[account nickname]];
    
    if(!dict){
        DynamicTableCellInfo * cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"ErrorCell" andCellReusableId:@"ErrorCell"];
        [cellInfo setText:@"Cannot read API Response"];
        [cellInfo setImageName:@"OTHER ISSUE"];
        
        [sectionInfo appendCell:cellInfo];
    }else if(![[dict objectForKey:@"code"] isEqualToString:@"OK"]){
        DynamicTableCellInfo * cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"ErrorCell" andCellReusableId:@"ErrorCell"];
        [cellInfo setText:[NSString stringWithFormat:@"%@",[dict objectForKey:@"data"]]];
        [cellInfo setImageName:@"OTHER ISSUE"];
        
        [sectionInfo appendCell:cellInfo];
    }else{
        NSArray * warnings=[[dict objectForKey:@"data"]objectForKey:@"warning"];
        if([warnings count]){
            DynamicTableCellInfo * cellInfo=nil;
            for(NSUInteger i=0;i<[warnings count];i++){
                NSDictionary*warning=[warnings objectAtIndex:i];
                
                cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:[NSString stringWithFormat:@"WARNING-%lu",(unsigned long)i] andCellReusableId:@"WarningCell"];
                [cellInfo setCellStyle:(UITableViewCellStyleSubtitle)];
                
                NSString * title=[NSString stringWithFormat:
                                  @"%@ [%@]",
                                  [warning objectForKey:@"hardware_type"],
                                  [warning objectForKey:@"instance"]
                                  ];
                NSString * detail=[NSString stringWithFormat:
                                   @"%@: %@ %@",
                                   [warning objectForKey:@"issue_type"],
                                   [warning objectForKey:@"issue_fact"],
                                   [warning objectForKey:@"issue_fact_unit"]
                                   ];
                if(
                   [warning objectForKey:@"sub_device"]
                   && ![[warning objectForKey:@"sub_device"] isKindOfClass:[NSNull class]]
                   && ![[warning objectForKey:@"sub_device"] isEqualToString:@""]
                   ){
                    detail = [detail stringByAppendingFormat:@" [%@]",[warning objectForKey:@"sub_device"]];
                }
                
                [cellInfo setText:title];
                [cellInfo setDetailText:detail];
                
                UIImage*image=[UIImage imageNamed:[warning objectForKey:@"issue_type"]];
                if(!image){
                    [cellInfo setImageName:@"OTHER ISSUE"];
                }
                [cellInfo setImageName:[warning objectForKey:@"issue_type"]];
                
                __weak DynamicTianwenWarningView*weakSelf=self;
                [cellInfo setOnSelect:^(DynamicTableCellInfo* _Nonnull cellInfo, id _Nullable otherInfo){
                    if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onSelectWarning:cellInfo:addition:)]){
                        [[weakSelf delegate]onSelectWarning:weakSelf
                                                   cellInfo:cellInfo
                                                   addition:@{
                                                              @"warning":warning,
                                                              @"account":account,
                                                              }
                         ];
                    }
                }];
                
                [sectionInfo appendCell:cellInfo];
            }
        }else{
            DynamicTableCellInfo * cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"NormalCell" andCellReusableId:@"NormalCell"];
            [cellInfo setText:[NSString stringWithFormat:@"%@",@"All Green."]];
            [cellInfo setImageName:@"NO ISSUE"];
            
            [sectionInfo appendCell:cellInfo];
        }
        
        [sectionInfo setFooter:[NSString stringWithFormat:@"Done on %@",[[dict objectForKey:@"data"]objectForKey:@"done_time"]]];
    }
    
    //now we have sectionInfo
    NSInteger existed_index=-1;
    for(NSUInteger i=0;i<[_sections count];i++){
        if([[[_sections objectAtIndex:i]sectionKey]isEqualToString:[sectionInfo sectionKey]]){
            existed_index=i;
            break;
        }
    }
    if(existed_index>=0){
//        [_sections removeObjectAtIndex:existed_index];
        [_sections replaceObjectAtIndex:existed_index withObject:sectionInfo];
    }else{
        [_sections addObject:sectionInfo];
    }
    
    [_warningTable reloadData];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_sections count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[_sections objectAtIndex:section]cells]count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DynamicTableCellInfo*cellInfo=[[[_sections objectAtIndex:indexPath.section]cells]objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[cellInfo cellReusableId]];
    if(!cell){
        cell = [[UITableViewCell alloc]initWithStyle:[cellInfo cellStyle] reuseIdentifier:[cellInfo cellReusableId]];
    }
    
    // Configure the cell...
    //if([cellInfo text]){
    [[cell textLabel]setText:[cellInfo text]];
    //}
    //if([cellInfo detailText]){
    [[cell detailTextLabel]setText:[cellInfo detailText]];
    //}
    //if([cellInfo imageName]){
    [[cell imageView]setImage:[UIImage imageNamed:[cellInfo imageName]]];
    //}
    
    [cell setAccessoryType:[cellInfo cellAccessoryType]];
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    DynamicTableSectionInfo*sectionInfo=[_sections objectAtIndex:section];
    if([sectionInfo title]){
        return [sectionInfo title];
    }
    return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    DynamicTableSectionInfo*sectionInfo=[_sections objectAtIndex:section];
    if([sectionInfo title]){
        return [sectionInfo footer];
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DynamicTableCellInfo * cellInfo=[[[_sections objectAtIndex:indexPath.section]cells]objectAtIndex:indexPath.row];
    if(cellInfo && [cellInfo onSelect]){
        cellInfo.onSelect(cellInfo, nil);
    }
}


@end
