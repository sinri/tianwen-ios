//
//  AliyunAccountModel.m
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/18.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "AliyunAccountModel.h"

@implementation AliyunAccountModel

-(instancetype)initWithAKId:(nonnull NSString *)ak_id andAKSecret:(nonnull NSString *)ak_secret{
    self=[super init];
    if(self){
        _tokenType=@"AK";
        _username=ak_id;
        _password=ak_secret;
        _regions=@[];
        _nickname=ak_id;
    }
    return self;
}

-(instancetype)initWithUsername:(NSString *)username andPassword:(NSString *)password{
    self=[super init];
    if(self){
        _tokenType=@"UP";
        _username=username;
        _password=password;
        _regions=@[];
        _nickname=username;
    }
    return self;
}
-(instancetype)initWithJSON:(NSString*)json{
    self=[super init];
    if(self){
        NSDictionary*model_json=[NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:(NSJSONReadingMutableLeaves) error:nil];
        if([[model_json objectForKey:@"token_type"]isEqualToString:@"UP"]){
            _tokenType=@"UP";
        }else{
            _tokenType=@"AK";
        }
        _username=[model_json objectForKey:@"username"];
        _password=[model_json objectForKey:@"password"];
        _regions=[model_json objectForKey:@"regions"];
        if(!_regions){
            _regions=@[];
        }
        _nickname=[model_json objectForKey:@"nickname"];
        if(!_nickname){
            _nickname=_username;
        }

    }
    return self;
}

-(BOOL)isAKMode{
    return ([_tokenType isEqualToString:@"AK"]);
}
-(BOOL)isUPMode{
    return ([_tokenType isEqualToString:@"UP"]);
}

-(NSString*)computeAliyunAccountModelKey{
    NSString * key =[NSString stringWithFormat:@"%@;%@",[self tokenType],[self username]];
    return key;
}

-(NSString*)toJson{
    NSData*data=[NSJSONSerialization dataWithJSONObject:@{
                                                          @"token_type":_tokenType,
                                                          @"username":_username,
                                                          @"password":_password,
                                                          @"regions":_regions,
                                                          @"nickname":_nickname,
                                                          }
                                                options:(NSJSONWritingPrettyPrinted)
                                                  error:nil
                 ];
    return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}

+(void)addAccountToStore:(AliyunAccountModel*)model{
    NSString*json=[[NSUserDefaults standardUserDefaults]objectForKey:@"tianwen_accounts"];
    NSDictionary * d= json?[NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:(NSJSONReadingMutableLeaves) error:nil]:@{};
    NSMutableDictionary*accounts=[d mutableCopy];
    [accounts setObject:[model toJson] forKey:[model computeAliyunAccountModelKey]];
    json=[[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:accounts options:(NSJSONWritingPrettyPrinted) error:nil] encoding:NSUTF8StringEncoding];
    [[NSUserDefaults standardUserDefaults]setObject:json forKey:@"tianwen_accounts"];
}
+(NSDictionary<NSString*,AliyunAccountModel*>*)storedAccounts{
    NSString*json=[[NSUserDefaults standardUserDefaults]objectForKey:@"tianwen_accounts"];
    if(json){
        NSDictionary * d= [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:(NSJSONReadingMutableLeaves) error:nil];
        NSMutableDictionary * md=[@{} mutableCopy];
        for (NSString * key in d) {
            NSString * part=[d objectForKey:key];
            AliyunAccountModel * aam=[[AliyunAccountModel alloc]initWithJSON:part];
            [md setObject:aam forKey:[aam computeAliyunAccountModelKey]];
        }
        return md;
    }
    return @{};
}

+(void)removeAccountInStore:(NSString*)key{
    NSString*json=[[NSUserDefaults standardUserDefaults]objectForKey:@"tianwen_accounts"];
    NSDictionary * d= json?[NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:(NSJSONReadingMutableLeaves) error:nil]:@{};
    NSMutableDictionary*accounts=[d mutableCopy];
    [accounts removeObjectForKey:key];
    json=[[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:accounts options:(NSJSONWritingPrettyPrinted) error:nil] encoding:NSUTF8StringEncoding];
    [[NSUserDefaults standardUserDefaults]setObject:json forKey:@"tianwen_accounts"];
}

//const

+(NSDictionary*)fullRegionDict{
    return @{
             @"CN_NORTH_1" : @"cn-qingdao",
             @"CN_NORTH_2" : @"cn-beijing",
             @"CN_NORTH_3" : @"cn-zhangjiakou",
             @"CN_EAST_1" : @"cn-hangzhou",
             @"CN_EAST_2" :@"cn-shanghai",
             @"CN_SOUTH_1" :@"cn-shenzhen",
             @"HK" :@"cn-hongkong",
             @"AP_SOUTHEAST_1" :@"ap-southeast-1",
             @"AP_SOUTHEAST_2" :@"ap-southeast-2",
             @"AP_NORTHEAST_1" :@"ap-northeast-1",
             @"US_WEST_1" :@"us-west-1",
             @"US_EAST_1" :@"us-east-1",
             @"EU_CENTRAL_1" :@"eu-central-1",
             @"ME_EAST_1" :@"me-east-1",
             };
}
+(NSArray*)fullRegionDictKeys{
    return [[[self fullRegionDict]allKeys]sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return obj1>obj2;
    }];
}

@end
