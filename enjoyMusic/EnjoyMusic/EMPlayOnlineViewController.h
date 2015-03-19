//
//  EMPlayOnlineViewController.h
//  EnjoyMusic
//
//  Created by administrator on 14-9-28.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Songs.h"

@interface EMPlayOnlineViewController : UIViewController
<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)Songs* song;
@property(nonatomic,strong)NSMutableArray* songLoadUrl;




@property (strong, nonatomic) UISwipeGestureRecognizer *SwipeToLeftGesture;

@property (strong, nonatomic) UISwipeGestureRecognizer *SwipeTorightGesture;

@property(strong,nonatomic)UIPageControl *pageControl;

@property (strong, nonatomic) IBOutlet UILabel *songName;

@property (strong, nonatomic) IBOutlet UITableView *songlrcTableview;
@property (strong, nonatomic) IBOutlet UIButton *POP;
@property (strong, nonatomic)  UIImageView *photoImageview;




- (IBAction)songLoad:(id)sender;






- (IBAction)POP:(id)sender;

@property (strong, nonatomic) IBOutlet UISlider *progress;
- (IBAction)changeprogress:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *nowtimeLable;
@property (strong, nonatomic) IBOutlet UILabel *DurationLable;

- (IBAction)share:(id)sender;

- (IBAction)PlayPreviousSong:(id)sender;

- (IBAction)PlayNextSong:(id)sender;











@end
