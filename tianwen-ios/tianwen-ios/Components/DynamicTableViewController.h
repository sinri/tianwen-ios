//
//  DynamicTableViewController.h
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/22.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DynamicTableSectionInfo.h"

@interface DynamicTableViewController : UITableViewController

@property NSMutableArray<DynamicTableSectionInfo *>* _Nonnull sections;

-(BOOL)appendSection:(DynamicTableSectionInfo*_Nonnull)sectionInfo;
-(DynamicTableSectionInfo* _Nullable)getSectionInfoWithKey:(NSString*_Nonnull)sectionKey;
-(BOOL)removeSectionWithKey:(NSString*_Nonnull)sectionKey;
-(void)removeAllSectionInfo;

-(BOOL)appendCell:(DynamicTableCellInfo*_Nonnull)cellInfo toSectionWithKey:(NSString*_Nonnull)sectionKey;

@end
