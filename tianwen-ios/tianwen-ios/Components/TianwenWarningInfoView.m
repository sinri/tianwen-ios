//
//  TianwenWarningInfoView.m
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/20.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "TianwenWarningInfoView.h"
#import "TianwenAPI.h"

@implementation TianwenWarningInfoView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self){
        
    }
    return self;
}

-(void)loadDataForAccount:(AliyunAccountModel*)account{
    //[self clearMySubViews];
    
    [self showWaitingIndicator];
    
    [self performSelectorInBackground:@selector(downloadCheckData:) withObject:account];
}

-(void)downloadCheckData:(AliyunAccountModel*)account{
    if(!account){
        [self performSelectorOnMainThread:@selector(showErrorInfo:) withObject:@"Account is not available for common check." waitUntilDone:NO];
        return;
    }
    NSDictionary*dict=nil;
    if([account isAKMode]){
        dict=[TianwenAPI CloudAssetsDoctor:@"common" forAccount:account];
    }else if ([account isUPMode]){
        dict=[TianwenAPI CloudAssetsDoctor:@"commonWithCache" forAccount:account];
    }else{
        dict=@{@"code":@"FAIL",@"data":@"Account has mistake so cannot call API."};
    }
    if(!dict || ![[dict objectForKey:@"code"]isEqualToString:@"OK"]){
        [self performSelectorOnMainThread:@selector(showErrorInfo:) withObject:(dict?[dict objectForKey:@"data"]:@"Call API Failed") waitUntilDone:NO];
        return;
    }
    _reportDictionary=[[dict objectForKey:@"data"]objectForKey:@"report"];
    if(!_reportDictionary){
        _reportDictionary=@{};
    }
    
    _warningArray=[[dict objectForKey:@"data"]objectForKey:@"warning"];
    if(!_warningArray){
        _warningArray=@[];
    }
    
    _lastCheckTime=[[dict objectForKey:@"data"]objectForKey:@"done_time"];
    
    [self performSelectorOnMainThread:@selector(showWarningTable) withObject:nil waitUntilDone:NO];
}

-(void)clearMySubViews{
    [_waitingIndicator removeFromSuperview];
    _waitingIndicator=nil;
    [_warningTable removeFromSuperview];
    _warningTable=nil;
    [_errorInfo removeFromSuperview];
    _errorInfo=nil;
}

-(void)showWaitingIndicator{
    [self clearMySubViews];
    _waitingIndicator=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    [_waitingIndicator setCenter:(CGPointMake(self.frame.size.width/2,self.frame.size.height/2))];
    [self addSubview:_waitingIndicator];
    [_waitingIndicator startAnimating];
}

-(void)showErrorInfo:(NSString*)error{
    [self clearMySubViews];
    _errorInfo=[[UITextView alloc]initWithFrame:(CGRectMake(5, 5, self.frame.size.width-10, self.frame.size.height-10))];
    [_errorInfo setEditable:NO];
    [[_errorInfo layer]setBorderColor:[[UIColor redColor]CGColor]];
    [[_errorInfo layer]setCornerRadius:5];
    [_errorInfo setText:error];
    [_errorInfo setTextAlignment:(NSTextAlignmentCenter)];
    [self addSubview:_errorInfo];
}

-(void)showWarningTable{
    [self clearMySubViews];
    _warningTable=[[UITableView alloc]initWithFrame:(CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)) style:(UITableViewStylePlain)];
    [_warningTable setDelegate:self];
    [_warningTable setDataSource:self];
    [self addSubview:_warningTable];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _warningArray?[_warningArray count]:0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:@"TianwenWarningInfoViewCell"];
    if(!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"TianwenWarningInfoViewCell"];
    }
    
    NSDictionary * warning=[_warningArray objectAtIndex:indexPath.row];
    [[cell textLabel]setText:[warning objectForKey:@"description"]];
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSUInteger count=_warningArray?[_warningArray count]:0;
    return [NSString stringWithFormat:@"Totally %lu warning%@",(unsigned long)count,(count>1?@"s":@"")];
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return [NSString stringWithFormat:@"Check done on %@",_lastCheckTime];
}

@end
