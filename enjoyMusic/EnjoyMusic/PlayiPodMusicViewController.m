//
//  PlayiPodMusicViewController.m
//  EnjoyMusic
//
//  Created by administrator on 14-10-25.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import "PlayiPodMusicViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "EMAppDelegate.h"

@interface PlayiPodMusicViewController ()
{
    MPMediaItem* Item;
    EMAppDelegate* del;
}



@end

@implementation PlayiPodMusicViewController

static int flag = 0;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    del = [UIApplication sharedApplication].delegate;
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"sliderThumb_small.png"] forState:UIControlStateNormal];

}

-(void)viewWillAppear:(BOOL)animated{
    
    
    self.tabBarController.tabBar.hidden = YES;

    if (Item == nil || (Item != nil && Item != self.item)) {
        [del.PLAYER stop];
        [del.player stop];
        [del.playerForKM stop];
        [del.playerForiPod stop];
        [self.tabBarController.tabBar setHidden:YES];
        
        //接收参数
        Item = self.item;
        del.playerForiPod = [MPMusicPlayerController iPodMusicPlayer];  //获取系统全局播放器
        del.playerForiPod.shuffleMode = MPMusicShuffleModeOff;
        del.playerForiPod.repeatMode = MPMusicRepeatModeNone;
        [del.playerForiPod setQueueWithQuery :[MPMediaQuery playlistsQuery]];
        [del.playerForiPod setNowPlayingItem:Item];
        [del.playerForiPod play];
        [self.POPButton setBackgroundImage:[UIImage imageNamed:@"songlist_pause_normal.png"] forState:UIControlStateNormal];

        [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(refreshInerface) userInfo:nil repeats:YES];
    
     }

    
}


-(void)viewWillDisappear:(BOOL)animated{

    [self.tabBarController.tabBar setHidden:NO];
}





-(void)refreshInerface{

    Item = del.playerForiPod.nowPlayingItem;
    self.iPodSongName.text = [Item valueForProperty:MPMediaItemPropertyTitle];  //标题
    NSString* na = [Item valueForProperty:MPMediaItemPropertyArtist];          //艺术家
    NSString* nb = [Item valueForProperty:MPMediaItemPropertyAlbumTitle];     //专辑名
    self.iPodSongArtistAndAlbum.text = [NSString stringWithFormat:@"%@---%@",na,nb];

    MPMediaItemArtwork* artwork = [Item valueForProperty:MPMediaItemPropertyArtwork];
    self.ArtistHeader.image = [artwork imageWithSize:self.ArtistHeader.frame.size];    //加载专辑图片
    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    
}



-(void)updateProgress{

    if (del.playerForiPod.currentPlaybackTime != 0) {
        NSString* p = [Item valueForProperty:MPMediaItemPropertyPlaybackDuration];
        int duration = [p intValue];

        //通过此判断语句，能够将播放和滑动器的控制很好的联系在一起
        self.progressSlider.value = del.playerForiPod.currentPlaybackTime / duration;
        int minute = del.playerForiPod.currentPlaybackTime / 60 ;
        int s = (int)del.playerForiPod.currentPlaybackTime % 60;
        self.Nowtime.text = [NSString stringWithFormat:@"%02d:%02d",minute,s];
        //02表示有两位组成，不够的时候添0代替
        int minute1 = duration / 60 ;
        int s1 =  duration % 60;
        self.Duration.text = [NSString stringWithFormat:@"%02d:%02d",minute1,s1];
    }






}









- (IBAction)PlayOrPause:(id)sender {
    flag += 1 ;
    if (flag %2 == 0) {
        [self.POPButton setBackgroundImage:[UIImage imageNamed:@"songlist_pause_normal.png"] forState:UIControlStateNormal];
        [del.playerForiPod play];
    }
    
    
    else{
        [self.POPButton setBackgroundImage:[UIImage imageNamed:@"songlist_play_normal.png"] forState:UIControlStateNormal];
        [del.playerForiPod pause];
    }

    
}






- (IBAction)PlayNextsong:(id)sender {
    [del.playerForiPod skipToNextItem];
    [self refreshInerface];
}

- (IBAction)PlayPreviousSong:(id)sender {
    [del.playerForiPod skipToPreviousItem];
    [self refreshInerface];
}












- (IBAction)changeProgress:(id)sender {
    [del.playerForiPod stop];
    NSString* p = [Item valueForProperty:MPMediaItemPropertyPlaybackDuration];
    int duration = [p intValue];
    del.playerForiPod.currentPlaybackTime = self.progressSlider.value * duration;
    [del.playerForiPod play];
    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end




