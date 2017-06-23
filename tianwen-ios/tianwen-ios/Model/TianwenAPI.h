//
//  TianwenAPI.h
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/19.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AliyunAccountModel.h"

#ifdef DEBUG
#ifndef FOR_SCREENSHOT
#define FOR_SCREENSHOT
#endif
#endif

@interface TianwenAPI : NSObject

+(NSDictionary*)CloudAssetsDoctor:(NSString*)plan forAccount:(AliyunAccountModel*)account;

+(NSDictionary*)ProductList:(NSString*)type forAccount:(AliyunAccountModel*)account;

+(NSDictionary*)Product:(NSString*)type instance:(NSString*)instance_id inRegion:(NSString*)region_id forAccount:(AliyunAccountModel*)account;

@end
