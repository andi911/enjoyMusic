//
//  EMPlayOnlineViewController.m
//  EnjoyMusic
//
//  Created by administrator on 14-9-28.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import "EMPlayOnlineViewController.h"
#import "EMAppDelegate.h"
#import "MediaPlayer/MediaPlayer.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "UMSocial.h"
#import "EMLoadViewController.h"
@interface EMPlayOnlineViewController ()
{
    EMAppDelegate* del;
    Songs* Song;
    NSString* Lrc;
    NSMutableArray* lrcArray;//存储歌词
    NSMutableArray *timeArray;
    NSMutableDictionary *LRCDictionary;
    NSUInteger lrcLineNumber;
    int count;
    NSTimer* Tim;
    BOOL lrcExist;
    UIImageView *vie;
    
}

@end

@implementation EMPlayOnlineViewController
static int flag = 0;
static int inde = 0;
static int number = 0;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed=YES;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    del = [UIApplication sharedApplication].delegate;
    self.songlrcTableview.delegate   = self;
    self.songlrcTableview.dataSource = self;
    lrcArray      = [[NSMutableArray alloc]init];
    timeArray     = [[NSMutableArray alloc]init];
    LRCDictionary = [[NSMutableDictionary alloc]init];
    
    vie=[[UIImageView alloc]initWithFrame:self.songlrcTableview.frame];

    
    self.photoImageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height-150)];

    [self.progress setThumbImage:[UIImage imageNamed:@"sliderThumb_small.png"] forState:UIControlStateNormal];
    self.title = @"网络音乐";
    
    self.SwipeTorightGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(JudgeNumberOfPage)];
    self.SwipeTorightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    
    
    self.SwipeToLeftGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(JudgeNumberOfPage)];
    self.SwipeToLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    
    
    self.pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(140, 450, 40, 25)];
    self.pageControl.numberOfPages = 2;
    self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor greenColor];
    
    [self.view addSubview:self.pageControl];
    [self.view addGestureRecognizer:self.SwipeTorightGesture];
    [self.view addGestureRecognizer: self.SwipeToLeftGesture];
    
}




-(void)viewWillAppear:(BOOL)animated
{
        
    
     if (Song == nil || (Song != nil && Song != self.song)) {
        [del.PLAYER stop];
        [del.player stop];
        [del.playerForKM stop];
        [del.playerForiPod stop];
        
        //接收参数
        Song = self.song;
        inde = [del.OnLineSongArray indexOfObject:Song];
        [self startPlayNextsong];
    }
}

    
-(void)startPlayNextsong{
    
    [self showLrcBackgroundImage];
    
    self.pageControl.currentPage = number;
    [self songLink];    //返回一个带有songlink,lrclink属性的song对象
    NSString* songlink = [Song.SongLink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* songUrl = [[NSURL alloc]initWithString:songlink];
    del.PLAYER = [[MPMoviePlayerController alloc] initWithContentURL: songUrl ];
    [del.PLAYER play];
    
    //刷新进度
    [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(UpdateProgress:) userInfo:nil  repeats:YES];
    
    self.songName.text = Song.SongName;
    


    [self getLrc];
    if (lrcExist == YES) {
        Tim = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(showTime) userInfo:nil repeats:YES];
    }

    [self.POP setBackgroundImage:[UIImage imageNamed:@"songlist_pause_normal.png"] forState:UIControlStateNormal];
    
 
    
 //*********************************准备后台播放********************************
    UIBackgroundTaskIdentifier bgTask = 0;
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        [del.PLAYER play];
        UIApplication* app = [UIApplication sharedApplication];
        UIBackgroundTaskIdentifier newTask = [app beginBackgroundTaskWithExpirationHandler:nil];
        if (bgTask != UIBackgroundTaskInvalid) {
            [app endBackgroundTask:bgTask];
        }
        bgTask = newTask;
    }
    
    
    else{
        [del.PLAYER play];
    }
    
   //*****************************************************************
    
    
    

}


//************************后台运行网络播放*****************************

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    [application beginReceivingRemoteControlEvents];
}

//************************网络播放后台运行*****************************


-(void)JudgeNumberOfPage{

    number ++;
    if (number == 2) {
        number = 0;
    }
    if (number == 0) {
        [self showLrcBackgroundImage];
    }
    else {
    
        [self showdSingerHeaderImage];
    
    }
    self.pageControl.currentPage = number;

}




#pragma mark - 加载网络图片
-(void)showdSingerHeaderImage
{
    NSURL *url12=[[NSURL alloc]initWithString:[Song.SingerBigImageurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSData *data1 = [NSData dataWithContentsOfURL:url12];
    
    UIImage *image1 =[UIImage imageWithData:data1];
    if (image1 == nil) {
        image1 = [UIImage imageNamed:@"网络-无歌时词背景.png"];
    }
    
    self.photoImageview.image = image1;
    self.photoImageview.autoresizingMask = UIViewContentModeScaleAspectFit;
    [self.view insertSubview:self.photoImageview atIndex:0];
    self.songlrcTableview.hidden = YES;
    self.songlrcTableview.scrollEnabled = NO;
    vie.hidden = YES;
}




-(void)showLrcBackgroundImage{
    UIImage *image1 = [UIImage imageNamed:@"网络-歌词背景图片.png"];
    self.photoImageview.image = image1;
    [self.view insertSubview:self.photoImageview atIndex:0];

    self.songlrcTableview.hidden = NO;
    self.songlrcTableview.scrollEnabled = YES;

    vie.hidden = NO;

}






#pragma mark - 更新进度
-(void)UpdateProgress:(NSTimer *)time
{
    self.progress.value = del.PLAYER.currentPlaybackTime / del.PLAYER.duration;
    int minute = del.PLAYER.currentPlaybackTime/60;
    int ss = (int)del.PLAYER.currentPlaybackTime%60;
    self.nowtimeLable.text = [NSString stringWithFormat:@"%02d:%02d",minute,ss];
    self.DurationLable.text = [self timeToString:del.PLAYER.duration];
    
    //自动播放下一首
    
    if (self.progress.value > 0.992) {
        [del.PLAYER stop];
        [del.player stop];
        [self toPlayNextSongautomaticly];
    }

    
    
}


- (NSString *)timeToString:(int)time {
	return [NSString stringWithFormat:@"%02d:%02d", time / 60, time % 60];
}




//***************************************************************

#pragma mark - 实现手动显示歌词位置从而决定播放进度

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    if (lrcExist == YES) {
        [Tim invalidate];
        //    [del.player stop];

    }
}



-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    if (lrcExist == YES) {
        int mark;
        float x = targetContentOffset->x;
        float y = targetContentOffset->y;
        CGPoint point = CGPointMake(x, y);
        mark = [self.songlrcTableview indexPathForRowAtPoint:point].row;
        
        mark = mark + 4;
        NSArray *array = [timeArray[mark] componentsSeparatedByString:@":"];
        double currentTime = [array[0] intValue] * 60 + [array[1] doubleValue]; //把时间转换成秒
        del.PLAYER.currentPlaybackTime = currentTime;
        [del.PLAYER play];
        lrcLineNumber = mark;
        Tim = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(showTime) userInfo:nil repeats:YES];

    }
}


//***************************************************************





-(Songs*)songLink{

    int song_id =  Song.song_id;
    NSString* urlString = [NSString stringWithFormat:@"http://ting.baidu.com/data/music/links?songIds=%d",song_id];
    NSURL* Url = [[NSURL alloc] initWithString:urlString];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setURL:Url];
    //发送同步请求
    NSData* receive = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:receive options:NSJSONReadingMutableContainers error:nil];
    NSDictionary* nsd = [dic objectForKey:@"data"];
    NSArray* nsa = [nsd objectForKey:@"songList"];
    for (NSDictionary* nsdi in nsa ) {
        
        Song.SongLink = [nsdi objectForKey:@"songLink"];
        Song.lrcLink  = [nsdi objectForKey:@"lrcLink"];
        Song.SingerBigImageurl = [nsdi objectForKey:@"songPicRadio"];

    }

    return Song;


}










//************************************************************************






#pragma mark - 获取相应的歌词

-(void)getLrc{
    
    [timeArray removeAllObjects];
    [vie removeFromSuperview];

    NSString* p = Song.lrcLink;
    NSURL* urlforLrc = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"http://ting.baidu.com%@",p]];
    Lrc    = [NSString stringWithContentsOfURL:urlforLrc encoding:NSUTF8StringEncoding error:nil];
    NSArray* array = [Lrc componentsSeparatedByString:@"\n"];
        for (int i = 0; i < array.count; i ++) {
            NSString *linStr = [array objectAtIndex:i];
            NSArray* lineArray = [linStr componentsSeparatedByString:@"]"];
            
            if([lineArray[0] length]>8){
                NSString* s1 = [linStr substringWithRange:NSMakeRange(3,1)]; //取到冒号
                NSString* s2 = [linStr substringWithRange:NSMakeRange(6, 1)];
                
                //判断歌词是否正常
                 if([s1 isEqualToString:@":"]&&[s2 isEqualToString:@"."]) {
                    NSString* lrcStr = [lineArray objectAtIndex:1];//获取歌词文本
                    NSString* timeStr = [[lineArray objectAtIndex:0]substringWithRange:NSMakeRange(1, 8)]; //获取时间
                    [LRCDictionary setObject:lrcStr forKey:timeStr];
                    [timeArray addObject:timeStr];
                }
                
            }
            
            
            
            
        }
    
    if (timeArray.count == 0) {
        lrcExist = NO;
        vie.image = [UIImage imageNamed:@"无歌词.png"];
        vie.autoresizingMask = UIViewContentModeScaleAspectFill;
        [self.view addSubview:vie];
        self.songlrcTableview.scrollEnabled = NO;
    }
    else{
        lrcExist = YES;
        self.songlrcTableview.scrollEnabled = YES;
        self.songlrcTableview.hidden = NO;
        [self.songlrcTableview reloadData];

    }
    
    

}





- (void)showTime
{
    [self displaySondWord:del.PLAYER.currentPlaybackTime];//调用歌词函数
    
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


//使被选中的行移到中间
- (void)updateLrcTableView:(NSUInteger)lineNumber {
    lrcLineNumber = lineNumber;
     NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lrcLineNumber inSection:0];
      [self.songlrcTableview scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
      [self.songlrcTableview reloadData];
 }






#pragma mark - uitableview相关代理方法

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (lrcExist == YES) {
        return [timeArray count];

    }
    else{
    
        return 1000;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (lrcExist == YES) {
        static NSString *cellIdentifier = @"LRCCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        //去别处显示正在播放的歌词
        if (indexPath.row == lrcLineNumber) {
            cell.textLabel.text = LRCDictionary[timeArray[indexPath.row]];
            cell.textLabel.textColor = [UIColor colorWithRed:0.8 green:0 blue:1 alpha:1.0];
            cell.textLabel.font = [UIFont systemFontOfSize:15];
        } else {
            cell.textLabel.text = LRCDictionary[timeArray[indexPath.row]];
            cell.textLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0.5 alpha:0.5];
            cell.textLabel.font = [UIFont systemFontOfSize:13];
            
        }
        
        cell.backgroundColor = [UIColor clearColor];
        self.songlrcTableview.backgroundColor=[UIColor clearColor];
        [self.songlrcTableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];//消除格子线
        cell.textLabel.textAlignment = NSTextAlignmentCenter;//设置字体位于中间
        return cell;

    }
    else{
        UITableViewCell* cell = [[UITableViewCell alloc]init];
        return  cell;
    }
}





#pragma mark - 自定义函数实现自动播放下一首网络歌曲

//************************************************************************



-(void)toPlayNextSongautomaticly{
    
    inde += 1;
    if (inde == del.OnLineSongArray.count) {
        inde = 0;
    }
    Song = [del.OnLineSongArray objectAtIndex:inde];
    del.OnlinePlayerVC.song = Song;
    number = 0;
    [self startPlayNextsong];
}


- (IBAction)PlayPreviousSong:(id)sender {
    [del.PLAYER stop];
    inde --;
    
    if (inde == -1) {
        inde = del.OnLineSongArray.count - 1;
    }
    Song = [del.OnLineSongArray objectAtIndex:inde  ];
    del.OnlinePlayerVC.song = Song;
    number = 0;
    [self startPlayNextsong];
    
}



- (IBAction)PlayNextSong:(id)sender {
    [del.PLAYER stop];
    number = 0;
    [self toPlayNextSongautomaticly];
    
}




- (IBAction)POP:(id)sender {
    flag += 1 ;
    if (flag %2 == 0) {
        [self.POP setBackgroundImage:[UIImage imageNamed:@"songlist_pause_normal.png"] forState:UIControlStateNormal];
        [del.PLAYER play];
    }
    else{
        [self.POP setBackgroundImage:[UIImage imageNamed:@"songlist_play_normal.png"] forState:UIControlStateNormal];
        [del.PLAYER pause];
    
    }
    
}







- (IBAction)songLoad:(id)sender {
    [del.UrlAndNameForLoadSongs addObject:Song];

    if (del.loadVC == nil) {
        del.loadVC = [[EMLoadViewController alloc]initWithNibName:@"EMLoadViewController" bundle:nil];
    }
    [self.navigationController pushViewController:del.loadVC animated:YES];
    
}






- (IBAction)changeprogress:(id)sender {
    
    [del.PLAYER pause];
    [del.PLAYER setCurrentPlaybackTime:self.progress.value *del.PLAYER.duration];
    [del.PLAYER play];
    
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)share:(id)sender {
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"507fcab25270157b37000010"
                                      shareText:[NSString stringWithFormat:@"推荐你听一首好歌《%@》",Song.SongName]
                                     shareImage:[UIImage imageNamed:@"YMO_1101.JPG"]
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToTencent,UMShareToRenren,nil]
                                       delegate:nil];

}



@end






































