//
//  DynamicTianwenWarningView.m
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/22.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "DynamicTianwenWarningView.h"
#import "TianwenAPI.h"

#import "TianwenHelper.h"

#import "DynamicECSDetailViewController.h"
#import "DynamicRDSDetailViewController.h"
#import "DynamicREDISDetailViewController.h"


#import "TianwenSettings.h"

#import <Crashlytics/Crashlytics.h>

@interface DynamicTianwenWarningView ()

@property UIButton * addAccountBtn;

@end

@implementation DynamicTianwenWarningView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self){
        _sections=[@[] mutableCopy];
        
        _warningTable=[[UITableView alloc]initWithFrame:(CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)) style:(UITableViewStyleGrouped)];
        [_warningTable setDelegate:self];
        [_warningTable setDataSource:self];
        [self addSubview:_warningTable];
        
        [_warningTable setSeparatorStyle:(UITableViewCellSeparatorStyleNone)];
        
        
        __weak UITableView * weakTable=_warningTable;
        //__weak DynamicTianwenWarningView * weakSelf=self;
        
        weakTable.mj_header=[MJRefreshNormalHeader headerWithRefreshingBlock:^{
            //            if(weakTable.mj_header.isRefreshing){
            //                NSLog(@"上一轮刷新还没有结束。。。");
            //                return;
            //            }
            
            NSLog(@"刷新开始");
            
            // loading
            [self reloadData];
            
            [Answers logCustomEventWithName:@"Manually Load Warning" customAttributes:@{}];
            
            // 结束刷新
            [weakTable.mj_header endRefreshing];
            
            NSLog(@"刷新结束");
        }];
        // 设置自动切换透明度(在导航栏下面自动隐藏)
        weakTable.mj_header.automaticallyChangeAlpha = YES;
    }
    return self;
}

-(void)reloadData{
    if([self delegate] && [[self delegate] respondsToSelector:@selector(reloadAccountsForDynamicTianwenWarningView:)]){
        [self setAccounts:[[self delegate]reloadAccountsForDynamicTianwenWarningView:self]];
        NSLog(@"reload accounts from delegate: %@",[self accounts]);
    }
    
    [self loadDataForAccounts:_accounts];
}

-(void)loadDataForAccounts:(NSArray<AliyunAccountModel *> *)accounts{
    NSLog(@"accounts: %@",accounts);
    _accounts=accounts;
    
    _sections=[@[] mutableCopy];
    [_warningTable reloadData];
    
    if([accounts count]>0){
        
        if(_addAccountBtn){
            [_addAccountBtn removeFromSuperview];
            _addAccountBtn=nil;
        }
        
        for(NSUInteger i=0;i<[accounts count];i++){
            AliyunAccountModel *account=[accounts objectAtIndex:i];
            DynamicTableSectionInfo * sectionInfo=[[DynamicTableSectionInfo alloc]initWithSectionKey:[account computeAliyunAccountModelKey]];
            [sectionInfo setTitle:[account nickname]];
            
            DynamicTableCellInfo * cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"LoadingCell" andCellReusableId:@"LoadingCell"];
            [cellInfo setText:NSLocalizedString(@"Loading",@"加载中")];
            [cellInfo setImageName:@"LOADING"];
            
            [sectionInfo appendCell:cellInfo];
            
            [_sections addObject:sectionInfo];
        }
        
        [_warningTable reloadData];
        
        for(NSUInteger i=0;i<[accounts count];i++){
            [self performSelectorInBackground:@selector(loadWarningInfoInBackgroundForAccount:) withObject:[accounts objectAtIndex:i]];
        }
    }else{
        _addAccountBtn=[UIButton buttonWithType:(UIButtonTypeRoundedRect)];
        [_addAccountBtn setFrame:(CGRectMake(50, 200, self.frame.size.width-100, 50))];
        [[_addAccountBtn layer]setBackgroundColor:[UIColor whiteColor].CGColor];
        [[_addAccountBtn layer]setCornerRadius:10];
        [_addAccountBtn setTitle:NSLocalizedString(@"Add Account", @"") forState:(UIControlStateNormal)];
        [_addAccountBtn addTarget:self action:@selector(quickAddAccount:) forControlEvents:(UIControlEventTouchUpInside)];
        [self insertSubview:_addAccountBtn aboveSubview:_warningTable];
    }
}

-(void)quickAddAccount:(id)sender{
    [_delegate onAddAccountButton];
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
    NSString * section_title=[account nickname];
    if([account isAKMode]){
        section_title = [section_title stringByAppendingFormat:@" (%@)",NSLocalizedString(@"AccessKey Pair",@"阿里云子账号")];
    }else if([account isUPMode]){
        section_title = [section_title stringByAppendingFormat:@" (%@)",NSLocalizedString(@"Registered User",@"注册账户")];
    }
    [sectionInfo setTitle:section_title];
    
    if(!dict){
        DynamicTableCellInfo * cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"ErrorCell" andCellReusableId:@"ErrorCell"];
        [cellInfo setText:NSLocalizedString(@"Cannot read API Response",@"未能获取情报")];
        [cellInfo setImageName:@"OTHER ISSUE"];
        
        [sectionInfo appendCell:cellInfo];
    }else if(![[dict objectForKey:@"code"] isEqualToString:@"OK"]){
        DynamicTableCellInfo * cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"ErrorCell" andCellReusableId:@"ErrorCell"];
        [cellInfo setText:NSLocalizedString(@"Load Failed", @"")];
        [cellInfo setImageName:@"OTHER ISSUE"];
        
        __weak DynamicTianwenWarningView*weakSelf=self;
        [cellInfo setOnSelect:^(DynamicTableCellInfo* _Nonnull cellInfo, id _Nullable otherInfo){
            UIAlertController * ac=[UIAlertController alertControllerWithTitle:NSLocalizedString(@"Load Failed", @"") message:[NSString stringWithFormat:@"%@",[dict objectForKey:@"data"]] preferredStyle:(UIAlertControllerStyleAlert)];
            [ac addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                //
            }]];
            [weakSelf.delegate presentViewController:ac animated:YES completion:nil];
        }];
        
        [sectionInfo appendCell:cellInfo];
    }else{
        NSArray * warnings=[[dict objectForKey:@"data"]objectForKey:@"warning"];
        if([warnings count]){
            DynamicTableCellInfo * cellInfo=nil;
            if([[TianwenSettings warningDisplayStyle]isEqualToString:@"WarningDisplayStyleList"]){
                //old ways
                for(NSUInteger i=0;i<[warnings count];i++){
                    NSDictionary*warning=[warnings objectAtIndex:i];
                    
                    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:[NSString stringWithFormat:@"WARNING-%lu",(unsigned long)i] andCellReusableId:@"WarningCell"];
                    [cellInfo setCellStyle:(UITableViewCellStyleSubtitle)];
                    
                    NSString * title=[NSString stringWithFormat:
                                      @"%@ [%@]",
                                      [warning objectForKey:@"hardware_type"],
                                      [TianwenHelper hiddenForScreenshot:[warning objectForKey:@"instance"]]
                                      
                                      ];
                    NSString * issue_type_name=[warning objectForKey:@"issue_type"];
                    issue_type_name=NSLocalizedString(issue_type_name, @"");
                    NSString * unit_string=[warning objectForKey:@"issue_fact_unit"];
                    NSString * detail=[NSString stringWithFormat:
                                       @"%@: %@ %@",
                                       issue_type_name,//[warning objectForKey:@"issue_type"],
                                       [warning objectForKey:@"issue_fact"],
                                       NSLocalizedString(unit_string, @"")
                                       ];
                    if(
                       [warning objectForKey:@"sub_device"]
                       && ![[warning objectForKey:@"sub_device"] isKindOfClass:[NSNull class]]
                       && ![[NSString stringWithFormat:@"%@",[warning objectForKey:@"sub_device"]] isEqualToString:@""]
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
            }else if([[TianwenSettings warningDisplayStyle]isEqualToString:@"WarningDisplayStyleTree"]){
                //new ways
                NSArray * productsWarning=[self warningsGroupByProduct:warnings];
                for(NSUInteger i=0;i<[productsWarning count];i++){
                    NSDictionary * product_info=[[productsWarning objectAtIndex:i]objectForKey:@"product"];
                    
                    cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:[NSString stringWithFormat:@"WARNING-PRODUCT-%lu",(unsigned long)i] andCellReusableId:@"WarningProductCell"];
                    [cellInfo setCellStyle:(UITableViewCellStyleDefault)];
                    [cellInfo setIndentationLevel:0];
                    //[cellInfo setDetailText:[NSString stringWithFormat:@"%@",[TianwenHelper hiddenForScreenshot:[product_info objectForKey:@"instance_name"]]]];
                    //[cellInfo setText:[NSString stringWithFormat:@"%@",[product_info objectForKey:@"hardware_type"]]];
                    [cellInfo setText:[NSString stringWithFormat:@"%@ | %@",[NSString stringWithFormat:@"%@",[product_info objectForKey:@"hardware_type"]],[NSString stringWithFormat:@"%@",[TianwenHelper hiddenForScreenshot:[product_info objectForKey:@"instance_name"]]]]];
                    //[cellInfo setImageName:[NSString stringWithFormat:@"%@",[product_info objectForKey:@"hardware_type"]]];
                    
                    //初始化NSMutableAttributedString
                    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]init];
                    //设置字体颜色
                    NSString *str1 = [NSString stringWithFormat:@"%@",[product_info objectForKey:@"hardware_type"]];
                    NSDictionary *dictAttr1 = @{NSForegroundColorAttributeName:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7]};
                    NSAttributedString *attr1 = [[NSAttributedString alloc]initWithString:str1 attributes:dictAttr1];
                    [attributedString appendAttributedString:attr1];
                    
                    [attributedString appendAttributedString:[[NSAttributedString alloc]initWithString:@" "]];
                    //添加下划线
                    //设置字体倾斜度 NSObliquenessAttributeName
                    NSString *str10 = [NSString stringWithFormat:@"%@",[TianwenHelper hiddenForScreenshot:[product_info objectForKey:@"instance_name"]]];
                    NSDictionary *dictAttr10 = @{
                                                 //NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle),
                                                 //NSUnderlineColorAttributeName:[UIColor redColor],
                                                 NSObliquenessAttributeName:@(0.2),
                                                 NSForegroundColorAttributeName:[UIColor colorWithRed:0.95 green:0.1 blue:0.1 alpha:0.95]
                                                 };
                    NSAttributedString *attr10 = [[NSAttributedString alloc]initWithString:str10 attributes:dictAttr10];
                    [attributedString appendAttributedString:attr10];
                    
                    [cellInfo setTextWithAttributes:attributedString];
                    
                    [cellInfo setCellAccessoryView: [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",[product_info objectForKey:@"hardware_type"]]]]];
                    
                    [cellInfo setAdditionCellSettingsBlock:^(__kindof DynamicTableCellInfoCompatibleCell* _Nonnull cell){
                        [[cell detailTextLabel]setFont:[UIFont systemFontOfSize:20 weight:1]];
                    }];
                    
                    [sectionInfo appendCell:cellInfo];
                    
                    NSArray * product_warnings=[[productsWarning objectAtIndex:i] objectForKey:@"warnings"];
                    if(!product_warnings || [product_warnings count]==0){
                        cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"NormalCell" andCellReusableId:@"NormalCell"];
                        [cellInfo setText:[NSString stringWithFormat:@"%@",NSLocalizedString(@"All Green.",@"一切正常")]];
                        [cellInfo setImageName:@"NO ISSUE"];
                        
                        [sectionInfo appendCell:cellInfo];
                    }else{
                        for (NSUInteger j=0; j<[product_warnings count]; j++) {
                            NSDictionary * warning=[product_warnings objectAtIndex:j];
                            NSLog(@"new method get warning: %@",warning);
                            
                            cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:[NSString stringWithFormat:@"WARNING-PRODUCT-DETAIL-%lu-%lu",(unsigned long)i,(unsigned long)j] andCellReusableId:@"WarningProductDetailCell"];
                            [cellInfo setCellStyle:(UITableViewCellStyleValue1)];//1 or 2?
                            
                            NSString * title=[NSString stringWithFormat:@"%@",[warning objectForKey:@"issue_type"]];
                            title=NSLocalizedString(title,@"");
                            NSString * unit_string=[warning objectForKey:@"issue_fact_unit"];
                            NSString * detail=[NSString stringWithFormat:
                                               @"%@ %@",
                                               [warning objectForKey:@"issue_fact"],
                                               NSLocalizedString(unit_string, @"")
                                               ];
                            if(
                               [warning objectForKey:@"sub_device"]
                               && ![[warning objectForKey:@"sub_device"] isKindOfClass:[NSNull class]]
                               && ![[NSString stringWithFormat:@"%@",[warning objectForKey:@"sub_device"]] isEqualToString:@""]
                               ){
                                detail = [NSString stringWithFormat:@"%@ : [%@]",detail,[warning objectForKey:@"sub_device"]];
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
                            
                            //[cellInfo setCellAccessoryView: [[UIImageView alloc] initWithImage:[UIImage imageNamed:[warning objectForKey:@"issue_type"]]]];
                            
                            //[cellInfo setIndentationLevel:1];
                            
                            [sectionInfo appendCell:cellInfo];
                        }
                    }
                    
                }
            }
        }else{
            DynamicTableCellInfo * cellInfo=[[DynamicTableCellInfo alloc]initWithCellKey:@"NormalCell" andCellReusableId:@"NormalCell"];
            [cellInfo setText:[NSString stringWithFormat:@"%@",NSLocalizedString(@"All Green.",@"一切正常")]];
            [cellInfo setImageName:@"NO ISSUE"];
            
            [sectionInfo appendCell:cellInfo];
        }
        
        [sectionInfo setFooter:[NSString stringWithFormat:NSLocalizedString(@"Done on %@",@"于 %@"),[[dict objectForKey:@"data"]objectForKey:@"done_time"]]];
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

-(NSArray*)warningsGroupByProduct:(NSArray*)warnings{
    NSMutableDictionary<NSString*,NSMutableDictionary*> * md=[@{} mutableCopy];
    for (NSUInteger i=0; i<[warnings count]; i++) {
        NSDictionary * warning=[warnings objectAtIndex:i];
        
        // product key
        NSString * product_key=[NSString stringWithFormat:@"%@|%@",[warning objectForKey:@"hardware_type"],[warning objectForKey:@"instance_id"]];
        //NSLog(@"warningsGroupByProduct key=%@ existed=%@",product_key,[md objectForKey:product_key]);
        if(![md objectForKey:product_key]){
            //NSLog(@"warningsGroupByProduct key=%@ new",product_key);
            [md setObject:[@{
                             @"product":@{
                                     @"hardware_type":[warning objectForKey:@"hardware_type"],
                                     @"instance_name":[warning objectForKey:@"instance"],
                                     @"instance_id":[warning objectForKey:@"instance_id"],
                                     },
                             @"warnings":[@[] mutableCopy],
                             } mutableCopy] forKey:product_key];
        }
        [[[md objectForKey:product_key]objectForKey:@"warnings"]addObject:warning];
        //NSLog(@"warningsGroupByProduct key=%@ added=%@",product_key,[md objectForKey:product_key]);
    }
    return [md allValues];
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
    if([cellInfo textWithAttributes]){
        [[cell textLabel]setAttributedText:[cellInfo textWithAttributes]];
    }else{
        [[cell textLabel]setText:[cellInfo text]];
    }
    if([cellInfo detailTextWithAttributes]){
        [[cell detailTextLabel]setAttributedText:[cellInfo detailTextWithAttributes]];
    }else{
        [[cell detailTextLabel]setText:[cellInfo detailText]];
    }
    [[cell imageView]setImage:[UIImage imageNamed:[cellInfo imageName]]];
    
    
    [cell setIndentationLevel:[cellInfo indentationLevel]];
    
    if([cellInfo cellAccessoryView]){
        [cell setAccessoryView:[cellInfo cellAccessoryView]];
    }else{
        [cell setAccessoryType:[cellInfo cellAccessoryType]];
    }
    
    if([[cellInfo cellReusableId]isEqualToString:@"WarningProductCell"]){
        [cell setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.7]];
    }
    
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
