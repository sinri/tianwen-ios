//
//  SettingsViewController.h
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/18.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DynamicTableViewController.h"
#import "SinriAdView.h"

@interface SettingsViewController :
//DynamicTableViewController
UIViewController<UITableViewDelegate,UITableViewDataSource>

@property UITableView * table;

@property SinriAdView * adView;

@end
