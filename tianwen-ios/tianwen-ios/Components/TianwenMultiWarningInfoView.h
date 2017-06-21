//
//  TianwenMultiWarningInfoView.h
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/20.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunAccountModel.h"
#import "MJRefresh.h"

@class TianwenMultiWarningInfoView;

@protocol TianwenMultiWarningInfoViewDelegate <NSObject>

@optional
-(NSArray<AliyunAccountModel*>*)reloadAccountsForTianwenMultiWarningInfoView:(TianwenMultiWarningInfoView*)target;

@end

@interface TianwenMultiWarningInfoView : UIView
<UITableViewDelegate,UITableViewDataSource>

@property NSObject<TianwenMultiWarningInfoViewDelegate> * delegate;

@property UITableView * warningTable;

@property NSArray<AliyunAccountModel *> * accounts;
@property NSMutableArray * warningInfoByAccount;

-(instancetype)initWithFrame:(CGRect)frame;

-(void)loadDataForAccounts:(NSArray<AliyunAccountModel*>*)accounts;

@end
