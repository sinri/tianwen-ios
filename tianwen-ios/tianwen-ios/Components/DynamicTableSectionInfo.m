//
//  DynamicTableSectionInfo.m
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/22.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "DynamicTableSectionInfo.h"

@implementation DynamicTableSectionInfo

//-(instancetype)init{
//#warning Do not use this `init` in product
//    self=[super init];
//    if(self){
//        _sectionKey = [[NSUUID UUID] UUIDString];
//        _cells=[@[] mutableCopy];
//        _title=nil;
//    }
//    return self;
//    @throw [NSException exceptionWithName:@"Method Locked" reason:@"Do not use this `init` in product" userInfo:nil];
//}

-(instancetype)initWithSectionKey:(NSString *)sectionKey{
    self=[super init];
    if(self){
        _sectionKey = sectionKey;
        _cells=[@[] mutableCopy];
        _title=nil;
    }
    return self;
}

-(DynamicTableCellInfo* _Nullable)getCellInfoWithKey:(NSString* _Nonnull)cellKey{
    for (NSUInteger i=0; i<[_cells count]; i++) {
        if([[[_cells objectAtIndex:i]cellKey]isEqualToString:cellKey]){
            return [_cells objectAtIndex:i];
        }
    }
    return nil;
}

-(BOOL)appendCell:(DynamicTableCellInfo *)cellInfo{
    if([self getCellInfoWithKey:[cellInfo cellKey]]){
        return NO;
    }
    [_cells addObject:cellInfo];
    return YES;
}

-(BOOL)removeCellWithKey:(NSString *)cellKey{
    NSInteger target_index=-1;
    for (NSUInteger i=0; i<[_cells count]; i++) {
        if([[[_cells objectAtIndex:i]cellKey]isEqualToString:cellKey]){
            target_index=i;
            break;
        }
    }
    if(target_index<0){
        return NO;
    }
    [_cells removeObjectAtIndex:target_index];
    return YES;
}


@end
