//
//  TianwenMultiWarningInfoView.m
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/20.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "TianwenMultiWarningInfoView.h"
#import "TianwenAPI.h"

@implementation TianwenMultiWarningInfoView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self){
        _warningInfoByAccount=[@[] mutableCopy];
        
        _warningTable=[[UITableView alloc]initWithFrame:(CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)) style:(UITableViewStyleGrouped)];
        [_warningTable setDelegate:self];
        [_warningTable setDataSource:self];
        [self addSubview:_warningTable];
        
        __weak UITableView * weakTable=_warningTable;
        __weak TianwenMultiWarningInfoView * weakSelf=self;
        
        weakTable.mj_header=[MJRefreshNormalHeader headerWithRefreshingBlock:^{
//            if(weakTable.mj_header.isRefreshing){
//                NSLog(@"上一轮刷新还没有结束。。。");
//                return;
//            }
            
            NSLog(@"刷新开始");
            
            // loading
            if([weakSelf delegate] && [[weakSelf delegate] respondsToSelector:@selector(reloadAccountsForTianwenMultiWarningInfoView:)]){
                [weakSelf setAccounts:[[weakSelf delegate]reloadAccountsForTianwenMultiWarningInfoView:weakSelf]];
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
    
    _warningInfoByAccount=[@[] mutableCopy];
    
    for(NSUInteger i=0;i<[accounts count];i++){
        [_warningInfoByAccount addObject:@{
                                           @"account":[accounts objectAtIndex:i],
                                           @"error":@"Loading...",
                                           @"timestamp":@"Unknown",
                                           }];
    }
    
    for (NSUInteger i=0; i<[_warningInfoByAccount count]; i++) {
        [self performSelectorInBackground:@selector(loadAccountWarningDataInBackgroundForAccountIndex:) withObject:@(i)];
    }
}

-(void)loadAccountWarningDataInBackgroundForAccountIndex:(NSNumber*)index{
    AliyunAccountModel * account=[[_warningInfoByAccount objectAtIndex:[index unsignedIntegerValue]] objectForKey:@"account"];
    
    NSDictionary*dict=nil;
    if([account isAKMode]){
        dict=[TianwenAPI CloudAssetsDoctor:@"common" forAccount:account];
    }else if ([account isUPMode]){
        dict=[TianwenAPI CloudAssetsDoctor:@"commonWithCache" forAccount:account];
    }else{
        dict=nil;//@{@"code":@"FAIL",@"data":@"Account has mistake so cannot call API."};
    }
    NSMutableDictionary*existed=[[_warningInfoByAccount objectAtIndex:[index unsignedIntegerValue]] mutableCopy];
    if(!dict){
        [existed setObject:@"Tianwen API Failed" forKey:@"error"];
        [existed removeObjectForKey:@"warning"];
    }else if (![[dict objectForKey:@"code"]isEqualToString:@"OK"]){
        [existed setObject:[dict objectForKey:@"data"] forKey:@"error"];
        [existed removeObjectForKey:@"warning"];
    }else{
        [existed removeObjectForKey:@"error"];
        [existed setObject:[[dict objectForKey:@"data"]objectForKey:@"warning"] forKey:@"warning"];
        [existed setObject:[[dict objectForKey:@"data"]objectForKey:@"done_time"] forKey:@"timestamp"];
    }
    [_warningInfoByAccount replaceObjectAtIndex:[index unsignedIntegerValue] withObject:existed];
    
    [_warningTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_warningInfoByAccount count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSDictionary * d= [_warningInfoByAccount objectAtIndex:section];
    if(d && [d objectForKey:@"warning"]){
        return [[d objectForKey:@"warning"] count];
    }
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:@"TianwenMultiWarningInfoViewCell"];
    if(!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:@"TianwenMultiWarningInfoViewCell"];
    }
    
    NSDictionary*dict=[_warningInfoByAccount objectAtIndex:indexPath.section];
    if([dict objectForKey:@"error"]&&![[dict objectForKey:@"error"] isEqualToString:@""]){
        //[[cell textLabel]setText:@"(=_=)"];
        [[cell textLabel]setText:[dict objectForKey:@"error"]];
        [[cell detailTextLabel]setText:@""];
    }else{
        NSArray*list=[dict objectForKey:@"warning"];
        NSDictionary*warning=[list objectAtIndex:indexPath.row];
        
        //"hardware_type"=>$hardware_type,
        //        "instance"=>$instance,
        //        "issue_type"=>$issue_type,
        //        "issue_fact"=>$issue_fact,
        //        "sub_device"=>$sub_device,
        
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
        [[cell textLabel]setText:title];
        [[cell detailTextLabel]setText:detail];
        
        UIImage*image=[UIImage imageNamed:[warning objectForKey:@"issue_type"]];
        if(!image){
            image=[UIImage imageNamed:@"OTHER ISSUE"];
        }
        [[cell imageView]setImage:image];
    }
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSDictionary*dict=[_warningInfoByAccount objectAtIndex:section];
    AliyunAccountModel * account=[dict objectForKey:@"account"];
    NSArray * warningArray=[dict objectForKey:@"warning"];
    NSUInteger count=warningArray?[warningArray count]:0;
    return [NSString stringWithFormat:@"[%@] Totally %lu warning%@",[account nickname],(unsigned long)count,(count>1?@"s":@"")];
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    NSDictionary*dict=[_warningInfoByAccount objectAtIndex:section];
    return [NSString stringWithFormat:@"Check done on %@",[dict objectForKey:@"timestamp"]];
}


@end
