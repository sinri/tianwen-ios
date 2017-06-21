//
//  APIClient.h
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/19.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AliyunAccountModel.h"

@interface APIClient : NSObject

+(NSDictionary*_Nullable)callTianwenApi:(NSString*_Nonnull)subUrl withPostData:(nonnull NSDictionary*)data forAccount:(nullable AliyunAccountModel*)account;
+(NSData*_Nullable)callURL:(nonnull NSString*)url withPostData:(nonnull NSDictionary *)data;

@end
