//
//  ECSDetailViewController.h
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/21.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunAccountModel.h"

@interface ECSDetailViewController : UITableViewController

@property AliyunAccountModel *account;

@property NSString*regionId;
@property NSString*instanceId;

@property NSString * productError;
@property NSDictionary * productInfo;

-(instancetype)initWithInstanceId:(NSString*)instanceId andRegionId:(NSString*)regionId forAccount:(AliyunAccountModel*)account;

@end
