//
//  EMprogressCell.m
//  EnjoyMusic
//
//  Created by administrator on 14-9-22.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import "EMprogressCell.h"
#import "EMdownloader.h"


@implementation EMprogressCell



//.....................................................................
#pragma mark - 实现自定义方法
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        
        [self.progressView setFrame:CGRectMake(self.progressView.frame.origin.x, self.progressView.frame.origin.y,110 , self.progressView.frame.size.height)];
        
        self.textLabel.text = @"0%";
        self.accessoryView = self.progressView;
        
    }
    return self;
}

-(void)initWithdownloadURL:(NSURL *)url
{
    self.progressView.progress = 0.0f;
    self.downloadData = nil;
    self.downloadURL = url;
    self.download = [[EMdownloader alloc] initWithURL:url timeout:20];//设置请求时间限制为20秒
}
-(void)reset
{
    
    self.textLabel.text = @" ";
    self.progressView.progress = 0.0f;
    self.downloadData = nil;
    self.downloadURL = nil;
}
-(void)startWithDelegate:(id<EMdowmloadDelegate>)delegate{
    
    self.delegate = delegate;
    [self.download statrWithDelegate:self];
}




//*************************************************************
#pragma mark - 实现EMdowmloadDelegate代理的方法
-(void)EMDownloadProgress:(float)progress Percentage:(NSInteger)percentage{
    self.progressView.progress = progress;
    if ([self.delegate respondsToSelector:@selector(progressCellDownloadProgress:Percentage:EMProgressCell:)]) {
        [self.delegate progressCellDownloadProgress:progress Percentage:percentage EMProgressCell:self];
    }
}

-(void)EMDownFinshed:(NSData *)fileData{
    self.downloadData = fileData;
    if ([self.delegate respondsToSelector:@selector(progressCellDownloadFinished:EMProgressCell:)]) {
        [self.delegate progressCellDownloadFinished:fileData EMProgressCell:self];
    }
    
}


-(void)EMDownloadFail:(NSError *)error{
    
    if ([self.delegate respondsToSelector:@selector(progressCellDownloadFail:EMProgressCell:)]) {
        [self.delegate progressCellDownloadFail:error EMProgressCell:self];
        
    }
    
}

//*************************************************************










- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}








@end





