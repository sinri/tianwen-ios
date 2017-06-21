//
//  TianwenAPI.h
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/19.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AliyunAccountModel.h"

@interface TianwenAPI : NSObject

+(NSDictionary*)CloudAssetsDoctor:(NSString*)plan forAccount:(AliyunAccountModel*)account;

@end
