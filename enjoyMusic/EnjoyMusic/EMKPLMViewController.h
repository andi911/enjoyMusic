//
//  EMKPLMViewController.h
//  EnjoyMusic
//
//  Created by administrator on 14-10-16.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Songs.h"
@interface EMKPLMViewController : UIViewController
<AVAudioPlayerDelegate,UITableViewDataSource,UITableViewDelegate>



@property (strong, nonatomic) Songs* KSong;
@property (strong, nonatomic) IBOutlet UILabel *Nowtime;
@property (strong, nonatomic) IBOutlet UILabel *Duration;
@property (strong, nonatomic) IBOutlet UILabel *SongName;
@property (strong, nonatomic) IBOutlet UISlider *ProgressSlider;
@property (strong, nonatomic) IBOutlet UISlider *VoiceSlider;
- (IBAction)ChangeProgress:(id)sender;
- (IBAction)ChangeVoice:(id)sender;
- (IBAction)PlayOrPause:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *pop;
- (IBAction)Next:(id)sender;
- (IBAction)Previous:(id)sender;
- (IBAction)modechangButton:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *Musiclrc;

@property (strong, nonatomic) IBOutlet UIButton *modeButton;


- (IBAction)VoiceControl:(id)sender;




- (IBAction)ShareToOthers:(id)sender;








@end





