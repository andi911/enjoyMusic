//
//  EMMyDownloadMusicViewController.h
//  EnjoyMusic
//
//  Created by administrator on 14-10-14.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMMyDownloadMusicViewController : UIViewController

@property (strong, nonatomic) IBOutlet UISegmentedControl *SegmentForLoadmusic;

- (IBAction)ChangeModle:(id)sender;




@property (strong, nonatomic) IBOutlet UITableView *loadMusicList;



@property (strong, nonatomic) IBOutlet UIBarButtonItem *ShowDownloadProgress;

- (IBAction)ShowDownloadProgressButtonItem:(id)sender;

















@end
