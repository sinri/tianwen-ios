//
//  WelcomeViewController.h
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/18.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TianwenMultiWarningInfoView.h"

@interface WelcomeViewController : UIViewController
<TianwenMultiWarningInfoViewDelegate>

//@property UIScrollView * reportContainer;
@property TianwenMultiWarningInfoView * warningReportView;

@end
