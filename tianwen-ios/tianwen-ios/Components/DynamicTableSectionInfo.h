//
//  DynamicTableSectionInfo.h
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/22.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DynamicTableCellInfo.h"

@interface DynamicTableSectionInfo : NSObject

@property NSString * _Nonnull sectionKey;
@property NSString * _Nullable title;
@property NSString * _Nullable footer;
@property  NSMutableArray<DynamicTableCellInfo*>* _Nonnull  cells;

-(instancetype _Nonnull)initWithSectionKey:(NSString* _Nonnull)sectionKey;

-(DynamicTableCellInfo* _Nullable)getCellInfoWithKey:(NSString* _Nonnull)cellKey;
-(BOOL)appendCell:(DynamicTableCellInfo*_Nonnull)cellInfo;
-(BOOL)removeCellWithKey:(NSString* _Nonnull)cellKey;


@end
