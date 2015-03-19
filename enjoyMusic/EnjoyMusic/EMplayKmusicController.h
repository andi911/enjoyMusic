//
//  EMplayKmusicController.h
//  EnjoyMusic
//
//  Created by administrator on 14-10-11.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "Songs.h"
@interface EMplayKmusicController : UIViewController<AVAudioPlayerDelegate,UITableViewDelegate,UITableViewDataSource,AVAudioRecorderDelegate,UIActionSheetDelegate>
{
    AVAudioRecorder *recorder;
    NSTimer *timer;
    
    
}

@property(strong,nonatomic)Songs* KSong;



@property (strong, nonatomic) IBOutlet UITableView *KlrcviewTable;
@property (strong, nonatomic) IBOutlet UILabel *NowtimeLable;
@property (strong, nonatomic) IBOutlet UILabel *DurationLable;
@property (strong, nonatomic) IBOutlet UISlider *progresslider;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (retain, nonatomic) AVAudioPlayer *avPlay;


- (IBAction)pauseButton:(id)sender;



@property (strong, nonatomic) IBOutlet UIImageView *imageView;


- (IBAction)finshAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *finshActionButton;



@property (strong, nonatomic) IBOutlet UIButton *restartButton;

- (IBAction)restart:(id)sender;
@property (strong, nonatomic) IBOutlet UISlider *voiceSlider;

- (IBAction)voiceAction:(id)sender;
- (IBAction)VoiceControl:(id)sender;
@property (strong, nonatomic) IBOutlet UISlider *progress;









+(EMplayKmusicController *)shareMusicViewController;
-(void)StartPlayer;



@end
