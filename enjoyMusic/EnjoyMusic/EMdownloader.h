//
//  EMdownloader.h
//  EnjoyMusic
//
//  Created by administrator on 14-9-22.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import <Foundation/Foundation.h>

//for block
typedef void (^EMDownloadProgressBlock)(float progressValue,NSInteger percentage);
typedef void (^EMDownloadFinishedBlock)(NSData*  fileData);
typedef void (^EMDownloadFailBlock)(NSError* error);

@protocol EMdowmloadDelegate <NSObject>

@required
-(void)EMDownloadProgress:(float)progress  Percentage:(NSInteger)percentage;
-(void)EMDownFinshed:(NSData* )fileData;
-(void)EMDownloadFail:(NSError*) error;

@end




@interface EMdownloader : NSObject
<NSURLConnectionDataDelegate>

@property(nonatomic,strong)NSMutableData* receiveData;
@property(nonatomic,assign)float receiveBytes;
@property(nonatomic,assign)float exceptedBytes;
@property(nonatomic,strong)NSURLRequest* request;
@property(nonatomic,strong)NSURLConnection* connection;
@property(nonatomic,strong)EMDownloadProgressBlock progressDownloadBlock;
@property(nonatomic,strong)EMDownloadFinishedBlock progressFinishBlock;
@property(nonatomic,strong)EMDownloadFailBlock progressFailBlock;

@property(nonatomic,assign)NSInteger downloadPercentage;
@property(nonatomic,assign)float progress;
@property(nonatomic , strong)id<EMdowmloadDelegate>delegate;

-(id)initWithURL:(NSURL*)fileURL timeout:(NSInteger)timeout;
-(void)startWithDownloading:(EMDownloadProgressBlock)progressBlock  onFinished:
(EMDownloadFinishedBlock)finishedBlock onFail:(EMDownloadFailBlock)failBlock;

-(void)statrWithDelegate:(id<EMdowmloadDelegate>)delegate;
-(void)cancle;





@end
