//
//  AliyunAccountModel.h
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/18.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AliyunAccountModel : NSObject

@property NSString * tokenType;

@property NSString * nickname;

@property NSString * username;
@property NSString * password;

@property NSArray * regions;


-(instancetype)initWithAKId:(NSString*)ak_id andAKSecret:(NSString*)ak_secret;
-(instancetype)initWithUsername:(NSString*)username andPassword:(NSString*)password;

-(BOOL)isAKMode;
-(BOOL)isUPMode;

-(NSString*)computeAliyunAccountModelKey;

+(void)addAccountToStore:(AliyunAccountModel*)model;
+(NSDictionary<NSString*,AliyunAccountModel*>*)storedAccounts;
+(void)removeAccountInStore:(NSString*)key;

+(NSDictionary*)fullRegionDict;
+(NSArray*)fullRegionDictKeys;
@end
