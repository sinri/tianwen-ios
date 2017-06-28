//
//  DynamicTianwenWarningView.h
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/22.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DynamicTableSectionInfo.h"
#import "AliyunAccountModel.h"
#import "MJRefresh.h"

@class DynamicTianwenWarningView;

@protocol DynamicTianwenWarningViewDelegate <NSObject>

@optional
-(NSArray<AliyunAccountModel*>*)reloadAccountsForDynamicTianwenWarningView:(DynamicTianwenWarningView*)target;
@optional
-(void)onSelectWarning:(DynamicTianwenWarningView*)target cellInfo:(DynamicTableCellInfo*)cellInfo addition:(NSDictionary*)addition;

@end

@interface DynamicTianwenWarningView : UIView
<UITableViewDelegate,UITableViewDataSource>

@property NSObject<DynamicTianwenWarningViewDelegate> * delegate;

@property UITableView * warningTable;

@property NSArray<AliyunAccountModel *> * accounts;

@property NSMutableArray<DynamicTableSectionInfo*>*sections;

-(instancetype)initWithFrame:(CGRect)frame;

-(void)loadDataForAccounts:(NSArray<AliyunAccountModel*>*)accounts;

-(void)reloadData;

@end
