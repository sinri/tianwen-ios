//
//  AliyunRegionSwitchGroup.h
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/19.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunAccountModel.h"

@interface AliyunRegionSwitchGroup : UIControl

@property NSMutableArray * switchList;

-(instancetype)initWithFrame:(CGRect)frame andRegions:(NSArray*)regionList;
-(void)refreshSwitchs:(NSArray*)regionList;
-(NSArray*)regionsOpened;

@end
