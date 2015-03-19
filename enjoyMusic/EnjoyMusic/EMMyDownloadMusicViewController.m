//
//  EMMyDownloadMusicViewController.m
//  EnjoyMusic
//
//  Created by administrator on 14-10-14.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import "EMMyDownloadMusicViewController.h"
#import "EMAppDelegate.h"
#import "EMLoadViewController.h"

@interface EMMyDownloadMusicViewController ()
<UITableViewDataSource,UITableViewDelegate>
{
    EMAppDelegate* del;
    NSArray *typeList;
    NSMutableArray* DownloadArray;
    NSTimer* time;
    
}

@end


@implementation EMMyDownloadMusicViewController
static  int flag ;        //切换标记


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
    flag = 0;
    self.loadMusicList.delegate = self;
    self.loadMusicList.dataSource = self;
    
    UILabel *label = [[UILabel alloc]init];
    self.loadMusicList.tableFooterView = label;  //消除格子线
    DownloadArray = [[NSMutableArray alloc]init];
    
    //设置标题
    typeList = @[@"已下载",@"正在下载"];
    for (int i = 0; i<typeList.count; i++) {
        [self.SegmentForLoadmusic setTitle:[typeList objectAtIndex:i] forSegmentAtIndex:i];
    }
    
    [self.SegmentForLoadmusic setTitle:[typeList objectAtIndex:0] forSegmentAtIndex:0];
    [self changeStatement];
  
    
}


-(void)viewWillAppear:(BOOL)animated{

    self.tabBarController.tabBar.hidden = YES;
     time = [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(refreshData) userInfo:nil repeats:YES];

}

-(void)viewWillDisappear:(BOOL)animated{
    
    self.tabBarController.tabBar.hidden = NO;
    [time invalidate];

}




- (IBAction)ChangeModle:(id)sender {
    
    [DownloadArray removeAllObjects];
    flag = self.SegmentForLoadmusic.selectedSegmentIndex;
    [self changeStatement];
    
}


-(void)changeStatement{
    
    if (flag == 0) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    else {
        [DownloadArray addObject:del.DownloadFailedAccount];
        [DownloadArray addObject:del.UrlAndNameForLoadSongs];
        self.navigationItem.rightBarButtonItem = self.ShowDownloadProgress;
        
    }
    
    

}

-(void)refreshData{
    [self.loadMusicList reloadData];
}





#pragma mark - tableview的代理方法

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (flag == 0) {
        return 1;

    }
    else{
        return DownloadArray.count;
    
    }
}




-(NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (flag == 0) {
        return del.DownloadSuccessAccount.count ;
    }

    else{
    
        return [DownloadArray[section] count];
    
    }
    
    
}



- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (flag == 0) {
        NSString* s = [NSString stringWithFormat:@"已经下载%d首",del.DownloadSuccessAccount.count];
        return s;
    }

    
    
    else{
            NSString* n = [NSString stringWithFormat:@"有%d首下载失败",del.DownloadFailedAccount.count];
            NSString* s = [NSString stringWithFormat:@"有%d首正在下载",del.UrlAndNameForLoadSongs.count];
            NSArray* arr = @[n,s];
            return arr[section];
    
    }
    
    
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return 40;

}





-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CustomcellForDownload"];
    if (flag == 0) {
       Songs* p = [del.DownloadSuccessAccount objectAtIndex:indexPath.row];
        cell.textLabel.text = p.SongName ;
        return cell;
    }
    
     
    else{
          Songs*  song = DownloadArray[indexPath.section][indexPath.row];
        cell.textLabel.text = song.SongName;
        return cell;
    
    }
    

}


#pragma mark - 点击已下载歌曲实现播放功能
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (flag == 0) {
        Songs* so = [del.DownloadSuccessAccount objectAtIndex:indexPath.row];
        if (del.DownloadSuccessAccount.count != 0) {
            if ([del.LocalSongArray containsObject:so] == NO) {
                [del.LocalSongArray addObject:so];
            }
            
            if (del.LocalPlayerVC == nil) {
                del.LocalPlayerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LocalMusticVC"];
            }
            
            del.LocalPlayerVC.song = so;
            [self.navigationController pushViewController:del.LocalPlayerVC animated:YES];

            
        }
    }




}

















//跳转视图观察下载进度

- (IBAction)ShowDownloadProgressButtonItem:(id)sender {
    if (del.loadVC == nil) {
        del.loadVC = [[EMLoadViewController alloc]initWithNibName:@"EMLoadViewController" bundle:Nil];
    }
    [self.navigationController pushViewController:del.loadVC animated:YES];
}







- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end













