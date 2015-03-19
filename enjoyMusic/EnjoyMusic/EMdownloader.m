//
//  EMdownloader.m
//  EnjoyMusic
//
//  Created by administrator on 14-9-22.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import "EMdownloader.h"


@implementation EMdownloader



#pragma mark - 自定义方法实现

-(id)initWithURL:(NSURL *)fileURL timeout:(NSInteger)timeout{
    self = [super init];
    if (self) {
        self.receiveBytes  = 0;
        self.exceptedBytes = 0;
        self.receiveData = [[NSMutableData alloc] initWithLength:0];
        self.downloadPercentage = 0.0f;
        self.request = [[NSURLRequest alloc] initWithURL:fileURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:timeout];
        self.connection = [[NSURLConnection alloc]initWithRequest:self.request delegate:self startImmediately:NO];
    }
    return self;

}


-(void)statrWithDelegate:(id<EMdowmloadDelegate>)delegate{
    self.delegate = delegate;
    if (self.connection) {
        [self.connection start];
        self.progressFinishBlock   = nil;
        self.progressDownloadBlock = nil;
        self.progressFailBlock     = nil;
    }
    
}

-(void)startWithDownloading:(EMDownloadProgressBlock)progressBlock  onFinished:(EMDownloadFinishedBlock)finishedBlock onFail:(EMDownloadFailBlock)failBlock{
    if (self.connection) {
        [self.connection start];
        self.delegate = nil;
        self.progressDownloadBlock = [progressBlock copy];
        self.progressFailBlock     = [failBlock copy];
        self.progressFinishBlock   = [finishedBlock copy];
    }
    
}



-(void)cancle{
    if (self.connection) {
        [self.connection cancel];
    }
}





//.....................................................................
#pragma mark - NSURLConnection代理方法

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.receiveData appendData:data];
    NSInteger len = [data length];
    
    self.receiveBytes += len;
    

    
    if (self.exceptedBytes != NSURLResponseUnknownLength) {
        self.progress = ((self.receiveBytes / (float)self.exceptedBytes) * 100 )/ 100;
        self.downloadPercentage = self.progress * 100;
        if ([self.delegate respondsToSelector:@selector(EMDownloadProgress:Percentage:)]) {
            [self.delegate EMDownloadProgress:self.progress Percentage:self.downloadPercentage];
        }
        else{
            if (self.progressDownloadBlock) {
                self.progressDownloadBlock(self.progress,self.downloadPercentage);
            }
        }
    }
}


-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if ([self.delegate respondsToSelector:@selector(EMDownloadFail:)]) {
        [self.delegate EMDownloadFail:error];
    }
    else{
    
        if (self.progressFailBlock) {
            self.progressFailBlock(error);
        }
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    self.connection = nil;
    if ([self.delegate respondsToSelector:@selector(EMDownFinshed:)] ) {
        [self.delegate EMDownFinshed:self.receiveData];
    }
    else{
        if (self.progressFinishBlock) {
            self.progressFinishBlock(self.receiveData);
        }
    }
}



//接收已下载完成的部分的数据
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    self.exceptedBytes = [response expectedContentLength];

}

//.....................................................................









@end




















