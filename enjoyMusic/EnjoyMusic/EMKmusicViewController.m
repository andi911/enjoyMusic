//
//  EMKmusicViewController.m
//  EnjoyMusic
//
//  Created by administrator on 14-10-11.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import "EMKmusicViewController.h"
#import "EMAppDelegate.h"
#import "Songs.h"
#import "EMplayKmusicController.h"
#import "CustomCell.h"
#import "TheMoreViewController.h"
#import "MBProgressHUD.h"
#import "UserLoginViewController.h"

#define KMUSICLINK @"http://10.110.2.151:8888/EnjoyMusic/PHP/index.php/home/high/loadhighmusic"

@interface EMKmusicViewController ()
{
    
    EMAppDelegate *del;
    NSFileManager* manager;   //判断歌曲是否下载
    NSMutableArray* KmusicSongArray;
    int temp;
    MBProgressHUD *HUD;
    
}

@end

@implementation EMKmusicViewController

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
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    self.kMusicviewTable.delegate    = self;
    self.kMusicviewTable.dataSource  = self;
    KmusicSongArray=[NSMutableArray array];
    del = [UIApplication sharedApplication].delegate;
    temp=0;
    manager = [NSFileManager defaultManager];
   
    
}

-(void)viewWillAppear:(BOOL)animated{

//    [KmusicSongArray removeAllObjects];
    UILabel *label = [[UILabel alloc]init];
    self.kMusicviewTable.tableFooterView = label;  //消除格子线
    if (KmusicSongArray.count == 0) {
        [self loadData];
    }

}





-(void)viewDidAppear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.tabBarController.tabBar setHidden:NO];
    

}

-(void)loadData
{
    NSURL *url = [NSURL URLWithString:KMUSICLINK];
    
    //创建Request请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setURL:url];
    
    //发送异步请求
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        //处理响应
        if (connectionError != nil) {
            NSLog(@"fail!%@",connectionError.localizedDescription);
        }
        else{
            //成功返回数据，解析JSON数据
            NSArray *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            for (NSDictionary *obj in dic) {
                Songs *m = [[Songs alloc]init];
                m.SongName = [obj objectForKey:@"songName"];
                
                m.author=[obj objectForKey:@"songAuthor"];
                
                m.smallpic =[obj objectForKey:@"songPicSmall"];
                
                m.SongLink =[obj objectForKey:@"songLink"];
                
                m.songAccompanyLink=[obj objectForKey:@"songAccompanyLink"];
                
                m.lrcLink=[obj objectForKey:@"ircLink"];
                
                [KmusicSongArray addObject:m];
                
                
            }
            
            //刷新TableVIEW
            [self.kMusicviewTable reloadData];
            
        }
    }];
    
    
    
    
    
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 60)];
    label.text=@"大家都在唱";
    label.font = [UIFont systemFontOfSize:15];
    label.textAlignment = NSTextAlignmentCenter;
    
    label.backgroundColor=[UIColor lightGrayColor];
    return label ;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}








- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [KmusicSongArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{


    return 50;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomCell";
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"CustomCell" owner:nil options:nil]lastObject];
    }
    
    Songs* n = [KmusicSongArray objectAtIndex:[indexPath row]];
    cell.tag= 100+ [indexPath row];
    
    cell.SongName.text   = n.SongName;
    cell.SongDetail.text = n.author;
    NSString *smallpic=[NSString stringWithFormat:@"http://10.110.2.151:8888%@",n.smallpic];
    
    [self loadImage:smallpic andIndexPath:indexPath];
    
    cell.ShowLrcStatement.hidden = YES;
    
    return cell;
    
}
//通过获取的URL地址得到歌手的小型图片
-(void)loadImage:(NSString*)urlPath andIndexPath:(NSIndexPath*)indexPath{
    //golobal dispatch queue.可以并发执行多个任务。但是执行任务的顺序是随机的
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL* Url = [NSURL URLWithString:[urlPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSData* data = [[NSData alloc] initWithContentsOfURL:Url];
        UIImage* image = [[UIImage alloc]initWithData:data];
        if (image != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CustomCell* cell = (CustomCell*)[self.kMusicviewTable cellForRowAtIndexPath:indexPath];
                cell.SingerImage.image = image;
                cell.SingerImage.layer.cornerRadius = 10;
                cell.SingerImage.layer.masksToBounds = YES;
                
                if (temp < del.OnLineSongArray.count) {
                    [self.kMusicviewTable reloadData];
                    temp ++;
                }
            });
        }
        
    });
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if (del.currentUser == nil) {
        
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"K歌前请先登录！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        [alert show];
        
    }

    
    
    
    
    else{
    
    [del.player stop];
    [del.PLAYER stop];
    [del.playerForiPod stop];
    [del.playerForKM stop];
    
    Songs *Song = [KmusicSongArray objectAtIndex:[indexPath row]];
    
    EMplayKmusicController *pushercontroller=[EMplayKmusicController  shareMusicViewController];
    
    pushercontroller.KSong = Song;
    
    
    //判断歌曲原唱是否存在，以便决定是否下载
    NSString* songPath = [NSString stringWithFormat:@"%@/%@.mp3",del.KMusicSourceFilePath,Song.SongName];
    NSFileManager* manag= [NSFileManager defaultManager];
    
    
    
    //####################################################
    //实现加载等待
    HUD = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUD];
    //如果设置此属性则当前的view置于后台
    HUD.labelText = @"加载中";
    //显示对话框
    [HUD showAnimated:YES whileExecutingBlock:^{
        if ([manag fileExistsAtPath:songPath] == NO) {
            NSString* getSongPath = [[NSString stringWithFormat:@"http://10.110.2.151:8888%@",Song.SongLink] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL* getSongUrl = [NSURL URLWithString:getSongPath];
            NSData* songData =  [[NSData alloc]initWithContentsOfURL:getSongUrl];
            [songData writeToFile:songPath atomically:YES];
            
        }
    }completionBlock:^{
        [HUD removeFromSuperview];
        HUD = nil;
        [self.navigationController pushViewController:pushercontroller animated:YES];
        
    }];
    
    
 }
    
    
    
    
    
}



-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if ( buttonIndex == 1) {
        UserLoginViewController* View = [[UserLoginViewController alloc]initWithNibName:@"UserLoginViewController" bundle:nil];
        [self.navigationController pushViewController:View animated:YES];

    }


}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


















