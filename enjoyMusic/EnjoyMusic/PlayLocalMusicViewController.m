//
//  PlayLocalMusicViewController.m
//  EnjoyMusic
//
//  Created by Administrator on 14-9-17.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import "PlayLocalMusicViewController.h"
#import "EMAppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ASIHTTPRequest.h"


@interface PlayLocalMusicViewController ()
{
    EMAppDelegate* del;
    NSString* lrcPath;
    NSMutableArray *timeArray;  //存储时间
    NSMutableDictionary *LRCDictionary;
    NSUInteger lrcLineNumber;
    NSFileManager* manager;
    int flag;                  //标记歌词是否存在
    UIImageView *vie;
    NSTimer* time;
    Songs* Song;
    
    int song_id;    //服务于歌词链接
    UILabel* label;   //显示模式
}

@end

@implementation PlayLocalMusicViewController

static int mode = 0;


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
    self.Musiclrc.delegate =  self;
    self.Musiclrc.dataSource = self;
    
    manager        =  [NSFileManager defaultManager];
    timeArray      =  [[NSMutableArray alloc] init];
    LRCDictionary  =  [[NSMutableDictionary alloc] init];
    label = [[UILabel alloc]initWithFrame:CGRectMake(93, 450, 134, 21)];
    vie = [[UIImageView alloc]initWithFrame:self.Musiclrc.frame];

    self.VoiceSlider.hidden = YES;
    
    [self.ProgressSlider setThumbImage:[UIImage imageNamed:@"sliderThumb_small.png"] forState:UIControlStateNormal];
    
   [ self.VoiceSlider setThumbImage:[UIImage imageNamed:@"sliderThumb_small.png"] forState:UIControlStateNormal];
    self.title = @"本地音乐"; 
    
    //**********************后台播放***********************
    
    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    
    
    
    //后台自动连播
    UIBackgroundTaskIdentifier oldTaskId = 0;
    UIBackgroundTaskIdentifier newTaskId = UIBackgroundTaskInvalid;
    [del.player play];
    newTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
    if (newTaskId != UIBackgroundTaskInvalid && oldTaskId != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask: oldTaskId];}
    oldTaskId = newTaskId;
    
    
    
    
    //****************************************************
  
    
    
}



-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];

    self.tabBarController.tabBar.hidden=YES;

    
    
    //避免同一首歌切换页面后从头播放，Song == nil表示首次进入，Song != nil && [Song.SongName isEqualToString:self.song.SongName]==NO
    //表示两首不同的歌
    if (Song == nil || (Song != nil && [Song.SongName isEqualToString:self.song.SongName]==NO)) {
        [del.PLAYER stop];
        [del.player stop];
        [del.playerForKM stop];
        [del.playerForiPod stop];
        [self.pop setImage:[UIImage imageNamed:@"songlist_pause_normal.png"] forState:UIControlStateNormal];
        
        //接收参数
        Song = self.song;
        [self StartPlayer];

    }
    
    //********************接收远程控制****************************
    
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication]beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
     //********************接收远程控制****************************
    
    

}



#pragma mark - 远程控制

-(void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];
    [self.tabBarController.tabBar setHidden:NO];
    [[UIApplication sharedApplication]endReceivingRemoteControlEvents];
    [self resignFirstResponder];

}

-(BOOL)canBecomeFirstResponder{

    return YES;

}


-(void)remoteControlReceivedWithEvent:(UIEvent *)event{

    if (event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self PlayOrPause:self.pop];
                break;
             case UIEventSubtypeRemoteControlPreviousTrack:
                [self Previous:self.Previous];
                case UIEventSubtypeRemoteControlNextTrack:
                [self Next:self.next];
            default:
                break;
        }
    }


}

//**************************************************************************



//实现播放功能
-(void)StartPlayer{
    
    lrcPath = [NSString stringWithFormat:@"%@/%@.lrc",del.SonglrcFilePath,Song.SongName];
    NSString* str  = [NSString stringWithFormat:@"%@/%@.mp3",del.LocalSongFilePath,Song.SongName] ;
    NSURL* urlPath = [NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    del.player    = [[AVAudioPlayer alloc]initWithContentsOfURL:urlPath error:nil];
    
    [del.player play];
    del.player.delegate = self;
    self.SongName.text = Song.SongName;
    self.Musiclrc.backgroundColor=[UIColor clearColor];
    [self getLrc];
    if ([del.player isPlaying]) {
        [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(UpdateProgress:) userInfo:nil repeats:YES];
        if (flag == 1) {
      time = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(showTime) userInfo:nil repeats:YES];

        }
    }
 
}



//封装方法从路径中获取歌词文本
-(void)getLrc{
    [timeArray removeAllObjects];
      if ([manager fileExistsAtPath:lrcPath]) {
        flag = 1;
        [vie removeFromSuperview];
        self.Musiclrc.scrollEnabled = YES;
          
        self.LoadLrcButton.enabled = NO;
        self.LoadLrcButton.hidden = YES;
          
        [timeArray removeAllObjects];
        self.Musiclrc.backgroundColor=[UIColor clearColor];//消除tableview的背景
        //获取歌词 contentStr
        NSString *contentStr = [NSString stringWithContentsOfFile:lrcPath encoding:NSUTF8StringEncoding error:nil];
        NSArray* array = [contentStr componentsSeparatedByString:@"\n"];
        for (int i = 0; i < array.count; i ++) {
            NSString *linStr = [array objectAtIndex:i];
            NSArray* lineArray = [linStr componentsSeparatedByString:@"]"];
            if([lineArray[0] length]>8){
                NSString* s1 = [linStr substringWithRange:NSMakeRange(3,1)]; //取到冒号
                NSString* s2 = [linStr substringWithRange:NSMakeRange(6, 1)];
                
                if([s1 isEqualToString:@":"]&&[s2 isEqualToString:@"."]) {
                     NSString* lrcStr = [lineArray objectAtIndex:1];//获取歌词文本
                     NSString* timeStr = [[lineArray objectAtIndex:0]substringWithRange:NSMakeRange(1, 8)]; //获取时间
                    [LRCDictionary setObject:lrcStr forKey:timeStr];
                    [timeArray addObject:timeStr];
                }
            }
            
        }
          [self.Musiclrc  reloadData];
        
    }
     else{
         flag = 0;
         
         self.LoadLrcButton.enabled = YES;
         self.LoadLrcButton.hidden = NO;

         vie.image = [UIImage imageNamed:@"无歌词背景.jpg"];
         vie.autoresizingMask = UIViewContentModeScaleAspectFill;
         [self.view addSubview:vie];
         self.Musiclrc.scrollEnabled = NO;
     }
    
}




- (void)showTime
{
    [self displaySondWord:del.player.currentTime];//调用歌词函数
    
}


// 封装一个方法，动态显示歌词
- (void)displaySondWord:(NSUInteger)Time {
    for (int j = 0; j < timeArray.count; j ++) {
    
     NSArray *array = [timeArray[j] componentsSeparatedByString:@":"];
    double currentTime = [array[0] intValue] * 60 + [array[1] doubleValue]; //把时间转换成秒
    
  // ........................................................................
        //处理最后一句
        if (j == [timeArray count]-1) {
            NSArray *array1 = [timeArray[timeArray.count-1] componentsSeparatedByString:@":"];
            double currentTime1 = [array1[0] intValue] * 60 + [array1[1] doubleValue];
            if (Time > currentTime1) {
                [self updateLrcTableView:j];
                break;
            }
        }
        else {
            //求出第一句的时间点，在第一句显示前的时间内一直加载第一句
            NSArray *array2 = [timeArray[0] componentsSeparatedByString:@":"];
            double currentTime2 = [array2[0] intValue] * 60 + [array2[1] doubleValue];
            if (Time < currentTime2 ) {
                [self updateLrcTableView:0];
                break;
            }
            //求出下一步的歌词时间点，然后计算区间
            NSArray *array3 = [timeArray[j + 1] componentsSeparatedByString:@":"];
            double currentTime3 = [array3[0] intValue] * 60 + [array3[1] doubleValue];
            if (Time >= currentTime && Time <= currentTime3) {
                [self updateLrcTableView:j];
                break;
                       }
             }
      }
    
}




//更新指定位置歌词显示
- (void)updateLrcTableView:(NSUInteger)lineNumber {
    lrcLineNumber = lineNumber;
        //使被选中的行移到中间
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lrcLineNumber inSection:0];

//    [self.Musiclrc selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
      [self.Musiclrc scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
      [self.Musiclrc reloadData];

}









- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//调节播放进度，快进快退
- (IBAction)ChangeProgress:(id)sender
{
    [del.player pause];
    [del.player setCurrentTime:self.ProgressSlider.value * del.player.duration];
    [del.player play];
}

//调节音量
- (IBAction)ChangeVoice:(id)sender
{
    del.player.volume = self.VoiceSlider.value;
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(HiddenVoiceIcon) userInfo:nil repeats:NO];
    
    
}

-(void)HiddenVoiceIcon{

    self.VoiceSlider.hidden = YES;

}



//播放/暂停
- (IBAction)PlayOrPause:(id)sender
{
    if ([del.player isPlaying]) {
        [self.pop setImage:[UIImage imageNamed:@"songlist_play_normal.png"] forState:UIControlStateNormal];
        [del.player pause];
    }
    else{
        [self.pop setImage:[UIImage imageNamed:@"songlist_pause_normal.png"] forState:UIControlStateNormal];
        [del.player play];
    }
}




#pragma mark 播放下一首
- (IBAction)Next:(id)sender
{
    [self.pop setImage:[UIImage imageNamed:@"songlist_pause_normal.png"] forState:UIControlStateNormal];
    Song = [self NextSongObject];
    del.LocalPlayerVC.song = Song;
    [self StartPlayer ];
    
}

#pragma mark 获取下一首歌曲对象
-(Songs*)NextSongObject{
    NSUInteger i =  [del.LocalSongArray indexOfObject:Song];
    
    if (mode % 3 == 1) {
        i = (rand()%(del.LocalSongArray.count));
    } else if (mode % 3 == 2) {
        i = [del.LocalSongArray indexOfObject:Song];
    } else {
        if (i == [del.LocalSongArray count] - 1) {
            i = 0;
        } else {
            i++;
        }
        
    }
    Song = [del.LocalSongArray objectAtIndex:i];
    
    return Song;
    
}





#pragma mark 播放上一首
- (IBAction)Previous:(id)sender {
    [self.pop setImage:[UIImage imageNamed:@"songlist_pause_normal.png"] forState:UIControlStateNormal];
    Song = [self PreviousSongObject];
    del.LocalPlayerVC.song = Song;
    [self StartPlayer];
    
}


#pragma mark 获取上一首歌曲对象
-(Songs *)PreviousSongObject
{
    NSUInteger i =  [del.LocalSongArray indexOfObject:Song];
    if (mode%3 == 1) {
        i = (rand()%(del.LocalSongArray.count));
    } else if (mode%3 == 2) {
        i = [del.LocalSongArray indexOfObject:Song];
    } else {
        if (i == 0) {
            i = del.LocalSongArray.count - 1;
        } else {
            i--;
        }
    }
    Song = [del.LocalSongArray objectAtIndex:i];
    return Song;
}




#pragma mark - 切换模式模式
- (IBAction)modechangButton:(id)sender {

    mode ++;
    if (mode%3 == 1) {
        [self.modeButton setImage:[UIImage imageNamed:@"playmoderandom.png"] forState:UIControlStateNormal];
        [self showLable];
        
    }else if(mode%3 == 2)
    {
        [self.modeButton setImage:[UIImage imageNamed:@"playmodesinglecycle.png"] forState:UIControlStateNormal];
        [self showLable];
    }else{
        [self.modeButton setImage:[UIImage imageNamed:@"playmodecycle.png"] forState:UIControlStateNormal];
        [self showLable];
        
    }}



#pragma mark - 显示模式模式
-(void)showLable
{
    label.backgroundColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:15];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.bounds = CGRectMake(0, 0, 90, 25);
    label.layer.cornerRadius = 5;
    
    if (mode%3 == 1) {
        label.text=@"随机播放";
    }
    else if(mode%3 == 2)
    {
        
        label.text = @"单曲循环";
    }
    else{
        label.text = @"顺序播放";
    }
    
    [self.view addSubview:label];
    [UIView animateWithDuration:1 animations:^{
        label.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1 animations:^{
            label.alpha = 0;
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
        }];
    }];
    
}











//即时显示歌曲播放时间
-(void)UpdateProgress:(NSTimer*)time{
    if (del.player.playing) {
        //通过此判断语句，能够将播放和滑动器的控制很好的联系在一起
        self.ProgressSlider.value = del.player.currentTime / del.player.duration;
        int minute = del.player.currentTime / 60 ;
        int s = (int)del.player.currentTime % 60;
        //currentTime是以秒来计时
        
        self.Nowtime.text = [NSString stringWithFormat:@"%02d:%02d",minute,s];
        //02表示有两位组成，不够的时候添0代替
        int minute1 = del.player.duration / 60 ;
        int s1 = (int)del.player.duration % 60;
        self.Duration.text = [NSString stringWithFormat:@"%02d:%02d",minute1,s1];
    }
}

#pragma mark - 实现连续播放的委托方法
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    Song = [self NextSongObject];
    del.LocalPlayerVC.song = Song;
    
    [self StartPlayer];
}







#pragma mark - UItableview相关代理方法
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (flag == 1) {
            return [timeArray count];
    }
    else{
    
        return 1000;
    
    }
 }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(flag == 1){
    static NSString *cellIdentifier = @"LRCCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    //区别出并显示正在播放的歌词
    if (indexPath.row == lrcLineNumber) {
        cell.textLabel.text = LRCDictionary[timeArray[indexPath.row]];
        cell.textLabel.textColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:1.0];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
    } else {
        cell.textLabel.text = LRCDictionary[timeArray[indexPath.row]];
        cell.textLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        cell.textLabel.font = [UIFont systemFontOfSize:13];
    }
    
    [self.Musiclrc setSeparatorStyle:UITableViewCellSeparatorStyleNone];//消除格子线
    cell.textLabel.textAlignment = NSTextAlignmentCenter;//设置字体位于中间
    cell.backgroundColor = [UIColor clearColor];
        
     return cell;
    }
    else{
        UITableViewCell* cell = [[UITableViewCell alloc]init];
        return  cell;
    }
}








//***************************************************************

#pragma mark - 歌词链接
- (IBAction)LoadLrcForSong:(id)sender {
    
    NSString* u = [NSString stringWithFormat:@"http://tingapi.ting.baidu.com/v1/restserver/ting?method=baidu.ting.search.common&query=%@&page_size=1&page_no=1&format=json&from=ios&version=2.1.1",Song.SongName];
    NSString* encodedString =[u stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
   NSURL* url=[NSURL URLWithString:encodedString];
    
    ASIHTTPRequest* request = [[ASIHTTPRequest alloc] initWithURL:url];
    request.delegate = self;
    [request startAsynchronous];
    [request setTimeOutSeconds:25];
    
    
}

#pragma mark - request的代理方法
- (void)requestFinished:(ASIHTTPRequest *)request{
    NSData* data = [request responseData];
    NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSArray *arr=[dic objectForKey:@"song_list"];

    for (NSDictionary *kk in arr) {
         song_id = [[kk objectForKey:@"song_id"] intValue];
    }
    
    NSString* urlString = [NSString stringWithFormat:@"http://ting.baidu.com/data/music/links?songIds=%d",song_id];

    NSURL* Url = [[NSURL alloc] initWithString:urlString];
    NSMutableURLRequest* reque = [[NSMutableURLRequest alloc] init];
    [reque setURL:Url];
    NSData* receive = [NSURLConnection sendSynchronousRequest:reque returningResponse:nil error:nil];
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:receive options:NSJSONReadingMutableContainers error:nil];
    NSDictionary* nsd = [dict objectForKey:@"data"];
    NSArray* nsa = [nsd objectForKey:@"songList"];

    NSString* lrcLink;
    for (NSDictionary* nsdi in nsa ) {
        
   lrcLink  = [nsdi objectForKey:@"lrcLink"];
        
    }

    NSURL* urlforLrc = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"http://ting.baidu.com%@",lrcLink]];
    NSString* Lrc =  [NSString stringWithContentsOfURL:urlforLrc encoding:NSUTF8StringEncoding error:nil];
    NSString* path = [NSString stringWithFormat:@"%@/%@.lrc",del.SonglrcFilePath,Song.SongName];
    //把下载的歌词自动保存至沙盒文件中
    [Lrc writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    double curr = del.player.currentTime;
    [del.player stop];
    [self StartPlayer];
    del.player.currentTime = curr;
  
}


-(void)requestFailed:(ASIHTTPRequest*)request{
    self.LoadLrcButton.enabled = NO;
    self.LoadLrcButton.hidden = YES;
    
}






//***************************************************************

#pragma mark - 实现手动显示歌词位置从而决定播放进度

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{

    [time invalidate];
//    [del.player stop];

}



-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    int mark;
    float x = targetContentOffset->x;
    float y = targetContentOffset->y;
    CGPoint point = CGPointMake(x, y);
    mark = [self.Musiclrc indexPathForRowAtPoint:point].row;
    
    mark = mark + 4;
    NSArray *array = [timeArray[mark] componentsSeparatedByString:@":"];
    double currentTime = [array[0] intValue] * 60 + [array[1] doubleValue]; //把时间转换成秒
    del.player.currentTime = currentTime;
    [del.player play];
    lrcLineNumber = mark;
    time = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(showTime) userInfo:nil repeats:YES];
    
}


//***************************************************************

#pragma mark - 解码错误执行的动作
-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer*)player error:(NSError *)error{
    //解码错误执行的动作
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"您好" message:@"当前歌曲解码错误，无法播放。" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    [del.player play];
}

#pragma mark - 处理中断的代码
-(void)audioPlayerBeginInteruption:(AVAudioPlayer*)player{
    //处理中断的代码
    [del.player stop];
}

#pragma mark - 处理中断结束的代码
-(void)audioPlayerEndInteruption:(AVAudioPlayer*)player{
    //处理中断结束的代码
    [del.player playAtTime:[del.player currentTime]];
}
//***************************************************************







- (IBAction)VoiceControl:(id)sender {
    
    self.VoiceSlider.hidden = NO;

}







@end












