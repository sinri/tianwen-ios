//
//  DynamicRDSDetailViewController.h
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/22.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "DynamicTableViewController.h"
#import "AliyunAccountModel.h"

@interface DynamicRDSDetailViewController : DynamicTableViewController

@property AliyunAccountModel * _Nonnull account;

@property NSString* _Nonnull regionId;
@property NSString* _Nonnull instanceId;
@property NSString* _Nonnull navTitle;

@property NSString * _Nullable RDSType;

-(instancetype _Nonnull)initWithInstanceId:(NSString*_Nonnull)instanceId andRegionId:(NSString*_Nonnull)regionId forAccount:(AliyunAccountModel*_Nonnull)account;

@end
