//
//  TianwenWarningInfoView.h
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/20.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunAccountModel.h"

@interface TianwenWarningInfoView : UIView
<UITableViewDelegate,UITableViewDataSource>

@property UITextView * errorInfo;
@property UIActivityIndicatorView *waitingIndicator;
@property UITableView * warningTable;

@property NSDictionary * reportDictionary;
@property NSArray * warningArray;
@property NSString * lastCheckTime;

-(instancetype)initWithFrame:(CGRect)frame;

-(void)loadDataForAccount:(AliyunAccountModel*)account;

@end
