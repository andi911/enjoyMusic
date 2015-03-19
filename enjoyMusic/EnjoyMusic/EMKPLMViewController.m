//
//  EMKPLMViewController.m
//  EnjoyMusic
//
//  Created by administrator on 14-10-16.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import "EMKPLMViewController.h"
#import "EMAppDelegate.h"
#import "ASIHTTPRequest.h"
#define uploadHighPath @"http://10.110.2.151:8888/EnjoyMusic/PHP/index.php/home/high/uploadhighmusic/"
#import "ASIFormDataRequest.h"
#import "UMSocial.h"

@interface EMKPLMViewController ()
{
    EMAppDelegate* del;
    NSString* lrcPath;
    NSMutableArray *timeArray;  //存储时间
    NSMutableDictionary *LRCDictionary;
    NSUInteger lrcLineNumber;
    NSFileManager* manager;
    int flag;                  //标记歌词是否存在
    UIImageView *vie;
    Songs* MyKSong;
    UILabel* label;   //显示模式

}

@end

@implementation EMKPLMViewController
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
    
    [self.VoiceSlider setThumbImage:[UIImage imageNamed:@"sliderThumb_small.png"] forState:UIControlStateNormal];
    [self.ProgressSlider setThumbImage:[UIImage imageNamed:@"sliderThumb_small.png"] forState:UIControlStateNormal];

    
}


-(void)viewWillAppear:(BOOL)animated{
    
    [self.pop setImage:[UIImage imageNamed:@"songlist_pause_normal.png"] forState:UIControlStateNormal];

    self.tabBarController.tabBar.hidden=YES;
    
    if (MyKSong == nil || (MyKSong != nil && MyKSong != self.KSong)) {
        [del.PLAYER stop];
        [del.player stop];
        [del.playerForKM stop];
        [del.playerForiPod stop];
        MyKSong = self.KSong;
        [self StartPlayer];

    }

    
 
}


-(void)viewWillDisappear:(BOOL)animated{

    self.tabBarController.tabBar.hidden=NO;

}



-(void)StartPlayer
{
    NSArray* array = [MyKSong.SongName componentsSeparatedByString:@"--"];
    NSString* ns  = [array firstObject];
    
    lrcPath = [NSString stringWithFormat:@"%@/%@.lrc",del.SonglrcFilePath,ns];
    
    NSString* str  = [NSString stringWithFormat:@"%@/%@.aac",del.UserKMusicFilePath,MyKSong.SongName] ;
    
    NSURL* urlPath = [NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    del.playerForKM = [[AVAudioPlayer alloc]initWithContentsOfURL:urlPath error:nil];
    [del.playerForKM play];
    
    del.playerForKM.delegate = self;
    NSArray* arr = [MyKSong.SongName componentsSeparatedByString:@"--"];
    NSString* name = [arr firstObject];
    self.SongName.text = name;
    self.Musiclrc.backgroundColor=[UIColor clearColor];
    
    [self getLrc];
    if ([del.playerForKM isPlaying]) {
        [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(fresh:) userInfo:nil repeats:YES];
        if (flag == 1) {
            [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(showTime) userInfo:nil repeats:YES];
            
        }
    }



}


//封装方法从路径中获取歌词文本
-(void)getLrc{
    
    [timeArray removeAllObjects];
    if ([manager fileExistsAtPath:lrcPath]) {
        flag = 1;
        [vie removeFromSuperview];
        [timeArray removeAllObjects];
        self.Musiclrc.backgroundColor=[UIColor clearColor];//消除tableview的背景
        //获取歌词 contentStr
        NSString *contentStr = [NSString stringWithContentsOfFile:lrcPath encoding:NSUTF8StringEncoding error:nil];
        NSArray* array = [contentStr componentsSeparatedByString:@"\n"];
        for (int i = 0; i < array.count; i ++) {
            NSString *linStr = [array objectAtIndex:i];
            NSArray* lineArray = [linStr componentsSeparatedByString:@"]"];
            //          NSLog(@"%@",lineArray);
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
        vie.image = [UIImage imageNamed:@"header.jpg"];
        [self.view addSubview:vie];
    }
    
}
- (void)showTime
{
    [self displaySondWord:del.playerForKM.currentTime];//调用歌词函数
    
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


//即时显示歌曲播放时间
-(void)fresh:(NSTimer*)time{
    if ([del.playerForKM isPlaying]) {
        //通过此判断语句，能够将播放和滑动器的控制很好的联系在一起
        self.ProgressSlider.value = del.playerForKM.currentTime / del.playerForKM.duration;
        int minute = del.playerForKM.currentTime / 60 ;
        int s = (int)del.playerForKM.currentTime % 60;
        
        self.Nowtime.text = [NSString stringWithFormat:@"%02d:%02d",minute,s];
        int minute1 = del.playerForKM.duration / 60 ;
        int s1 = (int)del.playerForKM.duration % 60;
        self.Duration.text = [NSString stringWithFormat:@"%02d:%02d",minute1,s1];
//        NSLog(@"%i  %i",s,s1);
    }
}


#pragma mark - 实现播放的委托方法
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    MyKSong = [self NextSongObject];
    del.UserKSongPlayVC.KSong = MyKSong;
    [self StartPlayer];
}



#pragma mark 获取下一首歌曲对象
-(Songs*)NextSongObject{
    NSUInteger i =  [del.MyKSongArray indexOfObject:MyKSong];
    
    if (mode % 3 == 1) {
        i = (rand()%(del.MyKSongArray.count));
    } else if (mode % 3 == 2) {
        i = [del.MyKSongArray indexOfObject:MyKSong];
    } else {
        if (i == [del.MyKSongArray count] - 1) {
            i = 0;
        } else {
            i++;
        }
        
    }
   
    
    MyKSong = [del.MyKSongArray objectAtIndex:i];
    return MyKSong;
    
}


#pragma mark 获取上一首歌曲对象
-(Songs *)PreviousSongObject
{
    NSUInteger i =  [del.MyKSongArray indexOfObject:MyKSong];
    
    if (mode % 3 == 1) {
        i = (rand()%(del.MyKSongArray.count));
    } else if (mode % 3 == 2) {
        i = [del.MyKSongArray indexOfObject:MyKSong];
    } else {
        if (i == 0) {
            i = del.LocalSongArray.count - 1;
        } else {
            i--;
        }
    }
    
    MyKSong = [del.MyKSongArray objectAtIndex:i];
    return MyKSong;
}
























- (IBAction)ChangeProgress:(id)sender {
    [del.playerForKM pause];
    [del.playerForKM setCurrentTime:self.ProgressSlider.value * del.playerForKM.duration];
    [del.playerForKM play];

}


- (IBAction)ChangeVoice:(id)sender {
    del.playerForKM.volume = self.VoiceSlider.value;
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(HiddenVoiceIcon) userInfo:nil repeats:NO];

}

-(void)HiddenVoiceIcon{
    
    self.VoiceSlider.hidden = YES;
    
}







- (IBAction)PlayOrPause:(id)sender {
    if ([del.playerForKM isPlaying]) {
        [self.pop setImage:[UIImage imageNamed:@"songlist_play_normal.png"] forState:UIControlStateNormal];
        [del.playerForKM pause];
    }
    else{
        [self.pop setImage:[UIImage imageNamed:@"songlist_pause_normal.png"] forState:UIControlStateNormal];
        [del.playerForKM play];
    }
}



#pragma mark - 播放下一首
- (IBAction)Next:(id)sender {
    [self.pop setImage:[UIImage imageNamed:@"songlist_pause_normal.png"] forState:UIControlStateNormal];
    MyKSong = [self NextSongObject];
    del.UserKSongPlayVC.KSong = MyKSong;
    [self StartPlayer ];
}


#pragma mark - 播放上一首
- (IBAction)Previous:(id)sender {
    
    [self.pop setImage:[UIImage imageNamed:@"songlist_pause_normal.png"] forState:UIControlStateNormal];
    MyKSong = [self PreviousSongObject];
    del.UserKSongPlayVC.KSong = MyKSong;
    [self StartPlayer];

}


#pragma mark 改变播放模式
- (IBAction)modechangButton:(id)sender {
    mode++;
    if (mode % 3==1) {
        [self.modeButton setImage:[UIImage imageNamed:@"playmoderandom.png"] forState:UIControlStateNormal];
    }else if(mode % 3==2)
    {
        [self.modeButton setImage:[UIImage imageNamed:@"playmodesinglecycle.png"] forState:UIControlStateNormal];
    }else{
        [self.modeButton setImage:[UIImage imageNamed:@"playmodecycle.png"] forState:UIControlStateNormal];
        
    }
    [self showLable];
}

#pragma mark 显示播放模式
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
        
        //区别显示正在播放的歌词
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




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)VoiceControl:(id)sender {
    self.VoiceSlider.hidden = NO;

}




#pragma mark -  用空间分享k歌

- (IBAction)ShareToOthers:(id)sender {
    
    [del.playerForKM pause];
    [self.pop setImage:[UIImage imageNamed:@"songlist_play_normal.png"] forState:UIControlStateNormal];

    NSString *url = [NSString stringWithFormat:uploadHighPath];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
 
    [request setFile:[NSString stringWithFormat:@"%@/%@.aac",del.UserKMusicFilePath,MyKSong] forKey:@"audio"];
    [request startSynchronous];
    
    if ([request complete]) {
        NSString* p = [MyKSong.SongName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [UMSocialSnsService presentSnsIconSheetView:self
                                             appKey:@"507fcab25270157b37000010"
                                          shareText:[NSString stringWithFormat:@"我的K歌很精彩哦，欢迎各位亲试听:http://10.110.2.151:8888/EnjoyMusic/PHP/Uploads/HighMusic/%@.aac",p]
                                         shareImage:[UIImage imageNamed:@"YMO_1101.JPG"]
                                    shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToTencent,UMShareToRenren,nil]
                                           delegate:nil];
    
    }
    
    
    else{
        
        UIAlertView* vi = [[UIAlertView alloc]initWithTitle:nil message:@"分享失败！" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [vi show];

        
        
    }
    
    
    
    
    
}








@end




