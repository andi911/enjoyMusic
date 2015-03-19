//
//  PlayLocalMusicViewController.h
//  EnjoyMusic
//
//  Created by Administrator on 14-9-17.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Songs.h"


@interface PlayLocalMusicViewController : UIViewController
<AVAudioPlayerDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property (strong, nonatomic)Songs* song;






@property (weak, nonatomic) IBOutlet UILabel *Nowtime;

@property (weak, nonatomic) IBOutlet UILabel *SongName;

@property (weak, nonatomic) IBOutlet UILabel *Duration;

@property (weak, nonatomic) IBOutlet UISlider *ProgressSlider;

@property (weak, nonatomic) IBOutlet UISlider *VoiceSlider;

- (IBAction)ChangeProgress:(id)sender;

- (IBAction)ChangeVoice:(id)sender;

- (IBAction)PlayOrPause:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *pop;

- (IBAction)Next:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *next;

- (IBAction)Previous:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *Previous;

- (IBAction)modechangButton:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *modeButton;
@property (strong, nonatomic) IBOutlet UITableView *Musiclrc;





@property (strong, nonatomic) IBOutlet UIButton *LoadLrcButton;

- (IBAction)LoadLrcForSong:(id)sender;






- (IBAction)VoiceControl:(id)sender;





@end
