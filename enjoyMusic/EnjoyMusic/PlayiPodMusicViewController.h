//
//  PlayiPodMusicViewController.h
//  EnjoyMusic
//
//  Created by administrator on 14-10-25.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface PlayiPodMusicViewController : UIViewController
<MPMediaPickerControllerDelegate>

@property(strong,nonatomic)MPMediaItem* item;





@property (strong, nonatomic) IBOutlet UILabel *iPodSongName;


@property (strong, nonatomic) IBOutlet UILabel *iPodSongArtistAndAlbum;


@property (strong, nonatomic) IBOutlet UIImageView *ArtistHeader;


@property (strong, nonatomic) IBOutlet UIButton *POPButton;

- (IBAction)PlayOrPause:(id)sender;


- (IBAction)PlayNextsong:(id)sender;


- (IBAction)PlayPreviousSong:(id)sender;

@property (weak, nonatomic) IBOutlet UISlider *progressSlider;

- (IBAction)changeProgress:(id)sender;



@property (weak, nonatomic) IBOutlet UILabel *Nowtime;

@property (weak, nonatomic) IBOutlet UILabel *Duration;










@end





