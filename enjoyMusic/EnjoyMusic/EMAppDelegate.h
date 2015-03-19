//
//  EMAppDelegate.h
//  EnjoyMusic
//
//  Created by Administrator on 14-9-12.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MediaPlayer/MediaPlayer.h"
#import "PlayLocalMusicViewController.h"
#import "EMPlayOnlineViewController.h"
#import "PlayiPodMusicViewController.h"
#import "User.h"
#import "EMKPLMViewController.h"




//定义下载页面为全局视图，不是每次跳转都需要重新创建，解决下载继续问题
#import "EMLoadViewController.h"


@interface EMAppDelegate : UIResponder <UIApplicationDelegate>


@property (strong, nonatomic) UIWindow *window;

@property(nonatomic,strong)NSString*  filePath;


//***********************文件夹***************************************

@property(nonatomic,strong)NSString* UserFilePath;         //存储用户名和密码
@property(nonatomic,strong)NSString* SonglrcFilePath;      //存储歌词
@property(nonatomic,strong)NSString* LocalSongFilePath;    //存储本地音乐
@property(nonatomic,strong)NSString* UserKMusicFilePath;   //存储用户K歌
@property(nonatomic,strong)NSString* KMusicSourceFilePath; //存储K歌源


//*******************************************************************


@property(nonatomic,strong)NSMutableArray* UrlAndNameForLoadSongs;     //存储要下载的歌曲的Song对象
@property(nonatomic,strong)NSMutableArray* DownloadSuccessAccount;   //存储已下载的歌曲
@property(nonatomic,strong)NSMutableArray* DownloadFailedAccount;   //存储下载失败歌曲



@property(nonatomic,strong)NSMutableArray* LocalSongArray;  //本地音乐文件
@property(nonatomic,strong)NSMutableArray* OnLineSongArray; //网络音乐文件
@property(nonatomic,strong)NSMutableArray* MyKSongArray;    //K歌文件
@property(nonatomic,strong)NSMutableArray* iPodSongArray;    //iPod歌文件


@property AVAudioPlayer            *  player;         //定义全局的本地播放器对象
@property MPMoviePlayerController  *  PLAYER;         //定义全局的网络播放器对象
@property AVAudioPlayer            *  playerForKM;    //定义全局的K歌文件播放器对象
@property MPMusicPlayerController  *  playerForiPod;  //定义全局的iPod播放器对象






@property BOOL IsLogin;   //定义全局布尔型，判断当前是否登录

@property (strong, nonatomic) User *currentUser;  //定义全局变量－－－－当前唯一用户














//**********************  进入下载页面 *******************************

@property(nonatomic, strong)EMLoadViewController *loadVC;
//***********************************************************

//**********************  进入本地播放页面 *******************************

@property(nonatomic, strong)PlayLocalMusicViewController *LocalPlayerVC;
//***********************************************************

//**********************  进入在线播放页面 *******************************

@property(nonatomic, strong)EMPlayOnlineViewController* OnlinePlayerVC;
//***********************************************************



//**********************  进入iPod播放页面 *******************************

@property(nonatomic, strong)PlayiPodMusicViewController* iPodPlayerVC;
//***********************************************************

//**********************  进入用户K歌播放页面 *******************************

@property(nonatomic, strong)EMKPLMViewController* UserKSongPlayVC;
//***********************************************************









@end



















