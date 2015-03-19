//
//  LocalMusicViewController.m
//  EnjoyMusic
//
//  Created by Administrator on 14-9-16.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import "LocalMusicViewController.h"
#import "SongListViewController.h"
#import "iPodMusicViewController.h"
#import "EMAppDelegate.h"
#import "LoadImageView.h"
#import "EMMyDownloadMusicViewController.h"
#import "EMKmusicListViewController.h"
#import "EMPlayOnlineViewController.h"
#import "TheMoreViewController.h"
#import "UserLoginViewController.h"

@interface LocalMusicViewController ()
{
    NSMutableArray *group;
    NSMutableArray *imageArr;
    NSMutableArray *imageArr2;
    EMAppDelegate* del;
}
@property (strong,nonatomic) NSTimer * timer;
@property (assign) int page;
@end

@implementation LocalMusicViewController


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
    [self initData];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    LoadImageView *loadView = [[[NSBundle mainBundle]loadNibNamed:@"LoadImageView" owner:nil options:nil]lastObject];
    self.tableView.tableHeaderView = loadView;
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@""]];
    [self.view insertSubview:imageView atIndex:0];
   
    del = [UIApplication sharedApplication].delegate;
    
    
    
    
//    //清理系统缓存
////    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSString* cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    
//        NSArray* files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];
//    
//    
//        for (NSString* p in files) {
//            NSError* error;
//            NSString* path = [cachPath stringByAppendingString:p];
//            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
//        }
//    
////    });
//    
    
    

}


-(void)viewWillAppear:(BOOL)animated{
    [self.tabBarController.tabBar setHidden:NO];

}



-(void)initData
{
    group = [[NSMutableArray alloc]init];
    imageArr  = [[NSMutableArray alloc]init];
    imageArr2 = [[NSMutableArray alloc]init];
    
    NSString *string1 = @"本地音乐";
    NSString *string2 = @"下载管理";
    NSString *string3 = @"我的K歌";
    NSString *string4 = @"iPod歌曲";
    NSMutableArray *arr1 = [NSMutableArray arrayWithObjects:string1, string2, string3, string4, nil];
    [group addObject:arr1];
    
    NSString *string5 = @" 当前播放";
//    NSString *string6 = @"";
    NSMutableArray *arr2 = [NSMutableArray arrayWithObjects:string5,nil];
    [group addObject:arr2];
    
    UIImage *image1 = [UIImage imageNamed:@"my_home_local_music.png"];
    UIImage *image2 = [UIImage imageNamed:@"my_home_download.png"];
    UIImage *image3 = [UIImage imageNamed:@"my_home_fav_list.png"];
    UIImage *image4 = [UIImage imageNamed:@"my_home_music_circle.png"];
    NSMutableArray *arr3 = [NSMutableArray arrayWithObjects:image1, image2, image3, image4, nil];
    imageArr = arr3;
    
    UIImage *image5 = [UIImage imageNamed:@"my_home_music_playing.png"];
    [imageArr2 addObject:image5];
//    UIImage *image6 = [UIImage imageNamed:@" "];
//    [imageArr2 addObject:image6];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 设置tableview的组数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [group count];
}

#pragma mark - 设置tableview的行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSMutableArray *arr = group[section];
    return arr.count;
}

#pragma mark - 返回每一行显示的具体数据
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    //    NSInteger section = [indexPath section];
    
    if ([indexPath section] == 0) {
        
        NSMutableArray *arr = group[indexPath.section];
        NSString *string = arr[indexPath.row];
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //设置分类
        cell.textLabel.text = string;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.imageView.image = imageArr[indexPath.row];
        
    }
    else if ([indexPath section] == 1) {
        
        NSMutableArray *arr = group[indexPath.section];
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        NSString *string = arr[indexPath.row];
        cell.textLabel.text = string ;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.imageView.image = imageArr2[indexPath.row];
        cell.imageView.autoresizingMask = UIViewContentModeScaleAspectFit;
        
    }
    

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        return 45;
    }
    else
        return 38;
}

#pragma mark - 选中
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([indexPath section] == 0 && [indexPath row] == 0) {
         SongListViewController *localSongListView = [self.storyboard instantiateViewControllerWithIdentifier:@"LocalSongListController"];
        [self.navigationController pushViewController:localSongListView animated:YES];
    }
    
    
    
    
    if ([indexPath section] == 0 && [indexPath row] == 1) {
        EMMyDownloadMusicViewController  *localDown=[self.storyboard instantiateViewControllerWithIdentifier:@"localDown"];
          [self.navigationController pushViewController:localDown animated:YES];
    }
    
    
    
    
    if ([indexPath section] == 0 && [indexPath row] == 2) {
        
        if (del.currentUser == nil) {
            
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"您好,请先登录！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
            [alert show];
            
        }

        
        else{
        EMKmusicListViewController *KlocalMusic=
        [self.storyboard instantiateViewControllerWithIdentifier:@"KlocalMusic"];
        [self.navigationController pushViewController:KlocalMusic animated:YES];
        }
    }
    
    
    
    
    if ([indexPath section] == 0 && [indexPath row] == 3) {
        iPodMusicViewController *ipodSongListView = [self.storyboard instantiateViewControllerWithIdentifier:@"ipodSongListController"];
        [self.navigationController pushViewController:ipodSongListView animated:YES];
    }
    
    
    if ([indexPath section] == 1 && [indexPath row] == 0) {
        
        if ([del.player isPlaying]) {
            
            if (del.LocalPlayerVC == nil) {
                del.LocalPlayerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LocalMusticVC"];
            }

            [self.navigationController pushViewController:del.LocalPlayerVC animated:YES];
        
        }
        
        if ([del.player isPlaying] ==NO && del.PLAYER.currentPlaybackTime != 0) {
            if (del.OnlinePlayerVC == nil) {
                del.OnlinePlayerVC = [[EMPlayOnlineViewController alloc]initWithNibName:@"EMPlayOnlineViewController" bundle:nil];
            }
            [self.navigationController pushViewController:del.OnlinePlayerVC animated:YES];
        }
        
        if (del.playerForiPod.currentPlaybackTime != 0) {
            if (del.iPodPlayerVC == nil) {
                del.iPodPlayerVC = [[PlayiPodMusicViewController alloc]initWithNibName:@"PlayiPodMusicViewController" bundle:nil];
            }
            
            [self.navigationController pushViewController:del.iPodPlayerVC animated:YES];

        }
        
        
        
        
        
    }
    
    
    
    
}




-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if ( buttonIndex == 1) {
        UserLoginViewController* View = [[UserLoginViewController alloc]initWithNibName:@"UserLoginViewController" bundle:nil];
        [self.navigationController pushViewController:View animated:YES];
        
    }
    
    
}





@end









