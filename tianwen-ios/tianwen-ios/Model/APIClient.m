//
//  APIClient.m
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/19.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "APIClient.h"

@implementation APIClient

+(NSDictionary*)callTianwenApi:(NSString*)subUrl withPostData:(NSDictionary*)data forAccount:(AliyunAccountModel*)account{
    NSMutableDictionary*md=[data mutableCopy];
    if([account isAKMode]){
        [md setObject:[account username] forKey:@"ak_id"];
        [md setObject:[account password] forKey:@"ak_secret"];
    }else if([account isUPMode]){
        [md setObject:[account username] forKey:@"username"];
        [md setObject:[account password] forKey:@"password"];
    }
    
    NSData*jsonData=[self callURL:[NSString stringWithFormat:@"https://tianwen.sinri.cc/%@",subUrl] withPostData:md];
    
    //NSLog(@"callTianwenApi for %@: %@",[account username],[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    
    if(!jsonData){
        return nil;
    }
    NSDictionary*dict=[NSJSONSerialization JSONObjectWithData:jsonData options:(NSJSONReadingMutableLeaves) error:nil];
    return dict;
}

+(NSData*)callURL:(NSString*)url withPostData:(NSDictionary*)data{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // app名称
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    // app版本
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    // app build版本
    //NSString *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    NSString*dataString=[NSString stringWithFormat:@"tianwen-client-name=%@&tianwen-client-version=%@",[APIClient URLEncode: app_Name],[APIClient URLEncode:app_Version]];
    for (NSString * key in data) {
        if([[data objectForKey:key] isKindOfClass:[NSArray class]]){
            for (NSUInteger i=0; i<[[data objectForKey:key]count]; i++) {
                id mono=[[data objectForKey:key] objectAtIndex:i];
                dataString=[dataString stringByAppendingFormat:@"&%@[]=%@",key,mono];
            }
        }else{
            dataString=[dataString stringByAppendingFormat:@"&%@=%@",key,[data objectForKey:key]];
        }
    }
    NSData*bodyData=[dataString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest*request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url] cachePolicy:(NSURLRequestReloadIgnoringCacheData) timeoutInterval:300];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:bodyData];
    [request addValue:[NSString stringWithFormat:@"%lu",(unsigned long)[bodyData length]] forHTTPHeaderField:@"Content-Length"];
    
    NSHTTPURLResponse * response=nil;
    NSError*error=nil;
    NSData*jsonData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(response.statusCode!=200 || error){
        NSLog(@"HTTP CODE: %ld",(long)response.statusCode);
        NSLog(@"HTTP ERROR: %@",error);
        return nil;
    }
    return jsonData;
}

+(NSString*)URLEncode:(NSString*)unescaped{
    NSString *escapedString = [unescaped stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    return escapedString;
}

@end
