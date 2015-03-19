//
//  EMprogressCell.h
//  EnjoyMusic
//
//  Created by administrator on 14-9-22.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMdownloader.h"

@class EMprogressCell;
@protocol progressCellDelegate <NSObject>

@required
-(void)progressCellDownloadProgress:(float)progress Percentage:(NSInteger)percentage EMProgressCell:(EMprogressCell*)cell;
-(void)progressCellDownloadFinished:(NSData*)fileData EMProgressCell:(EMprogressCell*)cell;
-(void)progressCellDownloadFail:(NSError*)error EMProgressCell:(EMprogressCell*)cell;

@end




@interface EMprogressCell : UITableViewCell
<EMdowmloadDelegate>


@property(nonatomic,strong)NSData* downloadData;
@property(nonatomic,strong)NSURL* downloadURL;
@property(nonatomic,strong)EMdownloader* download;
@property(nonatomic,strong)UIProgressView* progressView;

@property(nonatomic,strong)id<progressCellDelegate>delegate;




-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

-(void)startWithDelegate:(id<EMdowmloadDelegate>)delegate;

-(void)initWithdownloadURL:(NSURL*)url;
-(void)reset;

@end






