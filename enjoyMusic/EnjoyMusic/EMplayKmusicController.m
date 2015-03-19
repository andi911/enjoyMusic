//
//  EMplayKmusicController.m
//  EnjoyMusic
//
//  Created by administrator on 14-10-11.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//
#import "EMplayKmusicController.h"
#import "EMAppDelegate.h"
#import "ZJSwitch.h"

@interface EMplayKmusicController ()
{
    EMAppDelegate* del;
    NSMutableArray *timeArray;
    NSMutableDictionary *LRCDictionary;
    NSUInteger lrcLineNumber;
    NSFileManager* manager;
    Songs* KSongToPlay;
 

}

@end

@implementation EMplayKmusicController

static int markNumber = 0;      //服务于取消时删除
static int i=0;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


// 限制为单例模式
+(EMplayKmusicController *)shareMusicViewController
{
    static EMplayKmusicController * musicViewController;
    if (musicViewController == nil) {
        
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        musicViewController = [story instantiateViewControllerWithIdentifier:@"Kmusicplayer"];
        
    }
    return musicViewController;
    
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    recorder.delegate=self;
    
    manager        =  [NSFileManager defaultManager];
    timeArray      =  [[NSMutableArray alloc] init];
    LRCDictionary  =  [[NSMutableDictionary alloc] init];
    
    self.KlrcviewTable.delegate =  self;
    self.KlrcviewTable.dataSource = self;
    del = [UIApplication sharedApplication].delegate;
    del.playerForKM.delegate = self;
    [self.progress setThumbImage:[UIImage imageNamed:@"sliderThumb_small.png"] forState:UIControlStateNormal];
    [ self.voiceSlider setThumbImage:[UIImage imageNamed:@"sliderThumb_small.png"] forState:UIControlStateNormal];

    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
    
    //接收参数
    KSongToPlay = [[Songs alloc]init];
    KSongToPlay = self.KSong;
    
    self.voiceSlider.hidden=YES;
    
    [self StartPlayer];
    
    
}





-(void)loadswitch
{
    
    ZJSwitch *switch2 = [[ZJSwitch alloc] initWithFrame:CGRectMake(250, 75, 60, 31)];
    switch2.backgroundColor = [UIColor clearColor];
    switch2.tintColor = [UIColor orangeColor];
    switch2.textFont=[UIFont systemFontOfSize:7];
    switch2.onText  = @"原唱";
    switch2.offText = @"伴唱";
    [switch2 addTarget:self action:@selector(handleSwitchEvent:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:switch2];
    
}


- (void)handleSwitchEvent:(id)sender
{
    i ++ ;
    if (i % 2 == 1) {
        
        [del.playerForKM pause];
        NSString* strpath = [NSString stringWithFormat:@"%@/%@2.mp3",del.KMusicSourceFilePath,KSongToPlay.SongName] ;
        NSURL* urlPath = [NSURL URLWithString:[strpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [del.playerForKM stop];
        del.playerForKM    = [[AVAudioPlayer alloc]initWithContentsOfURL:urlPath error:nil];
        [del.playerForKM play];
        [del.playerForKM setCurrentTime:self.progresslider.value * del.playerForKM.duration];
    }
    
    
    
    else{
        [del.playerForKM pause];
        NSString* strpath = [NSString stringWithFormat:@"%@/%@.mp3",del.KMusicSourceFilePath,KSongToPlay.SongName] ;
         NSURL* urlPath = [NSURL URLWithString:[strpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        del.playerForKM  = [[AVAudioPlayer alloc]initWithContentsOfURL:urlPath error:nil];
        [del.playerForKM play];
        [del.playerForKM setCurrentTime:self.progresslider.value * del.playerForKM.duration];
    }
    
    
}




-(void)StartPlayer{
    
    markNumber = 0;
    [self.playButton setImage:[UIImage imageNamed:@"songlist_pause_normal.png"] forState:UIControlStateNormal];
    [self loadswitch];
    
    NSFileManager* manag= [NSFileManager defaultManager];
    
    
    //判断歌词是否存在，以便决定是否下载
    NSString* LrcPath  = [NSString stringWithFormat:@"%@/%@.lrc",del.SonglrcFilePath,KSongToPlay.SongName];

    if ([manag fileExistsAtPath:LrcPath] == NO) {
        NSString* getLrcPath = [[NSString stringWithFormat:@"http://10.110.2.151:8888%@",KSongToPlay.lrcLink] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL* getLrcUrl = [NSURL URLWithString:getLrcPath];
        NSData* LrcData =  [[NSData alloc]initWithContentsOfURL:getLrcUrl];
        [LrcData writeToFile:LrcPath atomically:YES];
    }
    
    
    NSString* songPath = [NSString stringWithFormat:@"%@/%@.mp3",del.KMusicSourceFilePath,KSongToPlay.SongName];
    NSURL* urlPath = [NSURL URLWithString:[songPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    del.playerForKM    = [[AVAudioPlayer alloc]initWithContentsOfURL:urlPath error:nil];
    [del.playerForKM play];
    
    
    [self SetRecorederParameter];
    [recorder record];
    NSInteger duration = del.playerForKM.duration;
    [recorder recordForDuration:duration];

    
    //设置定时检测声音大小，并以图片呈现出来
    timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];

    [self getLrc];
    
    
    if ([del.playerForKM isPlaying]) {
        [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(ShowProgress:) userInfo:nil repeats:YES];
        [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(showTime) userInfo:nil repeats:YES];
    }
    
    
    
    //**********************先下载原唱后下载伴唱,以节省缓冲时间***********************************
    
    NSString* AccompanySongPath =[NSString stringWithFormat:@"%@/%@2.mp3",del.KMusicSourceFilePath,KSongToPlay.SongName];

    if ([manag fileExistsAtPath:AccompanySongPath] == NO) {
        
        NSString* getAccompanySongName = [[NSString stringWithFormat:@"http://10.110.2.151:8888%@",KSongToPlay.songAccompanyLink] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL* getAccompanySongUrl = [NSURL URLWithString:getAccompanySongName];
        NSData* AccompanySongData = [[NSData alloc]initWithContentsOfURL:getAccompanySongUrl];
        [AccompanySongData writeToFile:AccompanySongPath atomically:YES];
        
        
    }
    
    
    //***************************************************************
    
    
}






#pragma mark - 封装方法从路径中获取歌词文本
-(void)getLrc{
    [timeArray removeAllObjects];
    NSString* LrcPath  = [NSString stringWithFormat:@"%@/%@.lrc",del.SonglrcFilePath,KSongToPlay.SongName];

        self.KlrcviewTable.backgroundColor=[UIColor clearColor];//消除tableview的背景
        NSString *contentStr = [NSString stringWithContentsOfFile:LrcPath encoding:NSUTF8StringEncoding error:nil];
        NSArray* array = [contentStr componentsSeparatedByString:@"\n"];
        for (int i = 0; i < array.count; i ++) {
            NSString *linStr = [array objectAtIndex:i];
            NSArray* lineArray = [linStr componentsSeparatedByString:@"]"];
            if([lineArray[0] length]>8){
                NSString* s1 = [linStr substringWithRange:NSMakeRange(3,1)]; //取到冒号
                NSString* s2 = [linStr substringWithRange:NSMakeRange(6, 1)];
                
                if([s1 isEqualToString:@":"]&&[s2 isEqualToString:@"."]) {
                    NSString* lrcStr = [lineArray objectAtIndex:1];//获取歌词文本
                    NSString* timeStr = [[lineArray objectAtIndex:0]substringWithRange:NSMakeRange(1, 8)];
                    [LRCDictionary setObject:lrcStr forKey:timeStr];
                    [timeArray addObject:timeStr];
                }
                
            }
            
    }
        
    
}





- (void)showTime
{
    [self displaySondWordtwo:del.playerForKM.currentTime];//调用歌词函数
    
}


// 封装一个方法，动态显示歌词
- (void)displaySondWordtwo:(NSUInteger)Time {
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
            if (Time < currentTime2 - 0.5) {
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
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lrcLineNumber inSection:0];
    [self.KlrcviewTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    [self.KlrcviewTable reloadData];
    
}


#pragma mark - 及时刷新歌曲播放进度
-(void)ShowProgress:(NSTimer*)time{
    if (del.playerForKM.playing) {
        self.progresslider.value = del.playerForKM.currentTime / del.playerForKM.duration;
        int minute = del.playerForKM.currentTime / 60 ;
        int s = (int)del.playerForKM.currentTime % 60;
        self.NowtimeLable.text = [NSString stringWithFormat:@"%02d:%02d",minute,s];
        int minute1 = del.playerForKM.duration / 60 ;
        int s1 = (int)del.playerForKM.duration % 60;
        self.DurationLable.text = [NSString stringWithFormat:@"%02d:%02d",minute1,s1];
    }
}






#pragma mark - uitableview相关代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [timeArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"LRCCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    
    //去别处显示正在播放的歌词
    if (indexPath.row == lrcLineNumber) {
        cell.textLabel.text = LRCDictionary[timeArray[indexPath.row]];
        cell.textLabel.textColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:1.0];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
    } else {
        cell.textLabel.text = LRCDictionary[timeArray[indexPath.row]];
        cell.textLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        cell.textLabel.font = [UIFont systemFontOfSize:13];
    }
    
    [self.KlrcviewTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];//消除格子线
    cell.textLabel.textAlignment = NSTextAlignmentCenter;//设置字体位于中间
    cell.backgroundColor = [UIColor clearColor];
    return cell;
    
}




- (IBAction)pauseButton:(id)sender {
    if ([del.playerForKM isPlaying]) {
        [self.playButton setImage:[UIImage imageNamed:@"songlist_play_normal.png"] forState:UIControlStateNormal];
        [del.playerForKM pause];
        [recorder pause];
    }
    
    
    else{
        [self.playButton setImage:[UIImage imageNamed:@"songlist_pause_normal.png"] forState:UIControlStateNormal];
        [del.playerForKM play];
        [recorder record];
    }
    
}


- (IBAction)finshAction:(id)sender {
    [del.playerForKM pause];
    [self.playButton setImage:[UIImage imageNamed:@"songlist_play_normal.png"] forState:UIControlStateNormal];
    double cTime = recorder.currentTime;
    if (cTime > 2) {//如果录制时间>2,保存
        //文件是自动保存的
    }
    else {
        //删除记录的文件
        [recorder deleteRecording];
    }
    
    [recorder stop];
    [timer invalidate];
    if (sender == self.finshActionButton) {
        UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:@"提示" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"保存K歌并返回" otherButtonTitles: nil];
        [sheet showInView:self.view];
    }
    
}



-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSString *ss=[NSString stringWithFormat:@"%@",[actionSheet buttonTitleAtIndex:buttonIndex]];
    
    if ([ss isEqualToString:@"保存K歌并返回"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
    else{
         [recorder deleteRecording];
         markNumber = 1;
     }
    
    
}


- (IBAction)restart:(id)sender {
    [self.playButton setImage:[UIImage imageNamed:@"songlist_pause_normal.png"] forState:UIControlStateNormal];
    //删除录制文件
    [recorder pause];
    [del.playerForKM pause];
    
    if (markNumber != 1) {
        [recorder deleteRecording];
    }
    
    [recorder stop];
    [timer invalidate];
    [self StartPlayer];

}





- (IBAction)voiceAction:(id)sender {
    del.playerForKM.volume = self.voiceSlider.value;
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(HiddenVoiceIcon) userInfo:nil repeats:NO];
}




-(void)HiddenVoiceIcon{
    
    self.voiceSlider.hidden = YES;
    
}




- (IBAction)VoiceControl:(id)sender {
    self.voiceSlider.hidden = NO;

}








//***********************************************************
#pragma mark - 设置录音设置参数
- (void)SetRecorederParameter
{
    //录音设置
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc]init] ;
    //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
    //录音通道数  1 或 2
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    //线性采样位数  8、16、24、32
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    
    
    NSString* path = [NSString stringWithFormat:@"%@/%@--%i.aac",del.UserKMusicFilePath,KSongToPlay.SongName,del.currentUser.userId];
    NSURL* url = [NSURL fileURLWithPath:path];
    
    NSError *error;
    //初始化
    recorder = [[AVAudioRecorder alloc]initWithURL:url settings:recordSetting error:&error];
    //开启音量检测
    recorder.meteringEnabled = YES;
    recorder.delegate = self;
}




#pragma mark - 实时监测声音大小

- (void)detectionVoice
{
    [recorder updateMeters];//刷新音量数据
    //获取音量的平均值  [recorder averagePowerForChannel:0];
    //音量的最大值  [recorder peakPowerForChannel:0];
    
    double lowPassResults = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
    if (0<lowPassResults<=0.06) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_01.png"]];
    }else if (0.06<lowPassResults<=0.13) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_02.png"]];
    }else if (0.13<lowPassResults<=0.20) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_03.png"]];
    }else if (0.20<lowPassResults<=0.27) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_04.png"]];
    }else if (0.27<lowPassResults<=0.34) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_05.png"]];
    }else if (0.34<lowPassResults<=0.41) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_06.png"]];
    }else if (0.41<lowPassResults<=0.48) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_07.png"]];
    }else if (0.48<lowPassResults<=0.55) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_08.png"]];
    }else if (0.55<lowPassResults<=0.62) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_09.png"]];
    }else if (0.62<lowPassResults<=0.69) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_10.png"]];
    }else if (0.69<lowPassResults<=0.76) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_11.png"]];
    }else if (0.76<lowPassResults<=0.83) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_12.png"]];
    }else if (0.83<lowPassResults<=0.9) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_13.png"]];
    }else {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_14.png"]];
    }
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end








