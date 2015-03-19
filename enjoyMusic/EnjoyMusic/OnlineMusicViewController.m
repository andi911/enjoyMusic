//
//  OnlineMusicViewController.m
//  EnjoyMusic
//
//  Created by Administrator on 14-9-16.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import "OnlineMusicViewController.h"
#import "EMprogressCell.h"
#import "EMAppDelegate.h"
#import "CustomCell.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "Songs.h"
#import "EMLoadViewController.h"
#import "MBProgressHUD.h"
#import "EMPlayOnlineViewController.h"
#import "MJRefresh.h"


@interface OnlineMusicViewController ()<UIActionSheetDelegate>
{
    EMAppDelegate * del;
    NSURL* url;
    int count;
    int mark;                                        //用以标记cell的行数
    NSMutableArray* songAndlrcLink;                 // 存储访问音乐实体及歌词
    MBProgressHUD *HUD;
    NSFileManager* manager;                        //判断歌曲是否下载
    Songs* PlayingSong;

  //定义三个数组，以作缓存只用，避免相同数据重复加载，占用网络资源
    NSMutableArray* arrayForNewSong;
    NSMutableArray* arrayForPopularSong;
    NSMutableArray* arrayForSearchsong;
    
    
}

@end

@implementation OnlineMusicViewController
static int flag = 1;
bool Judge;
static int sizeCount = 15;                  //开始下载数量
static int offsetCount = 0;                //下载偏移量
static int loadmoreTime = 0;              //加载更多次数

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
    self.loadSongUrlAndName  = [[NSMutableArray alloc]init];
    songAndlrcLink           = [[NSMutableArray alloc]init];
    
    arrayForNewSong          = [[NSMutableArray alloc]init];
    arrayForPopularSong      = [[NSMutableArray alloc]init];
    arrayForSearchsong       = [[NSMutableArray alloc]init];
    
    count = 0;
    del = [UIApplication sharedApplication].delegate;
    self.SongtableView.delegate   = self;
    self.SongtableView.dataSource = self;
    manager = [NSFileManager defaultManager];
 
    PlayingSong = [[Songs alloc]init];

    
}



-(void)viewWillAppear:(BOOL)animated{
    
    
    [self displaySongs];
    [self setuprefresh];
    [del.OnLineSongArray removeAllObjects];
    
  //再次返回页面看是否有资源可以加载，以节省网络资源
    
    if (flag == 1 && arrayForNewSong.count != 0  ) {
            for ( Songs* s  in arrayForNewSong) {
                [del.OnLineSongArray addObject:s];
            }
            [self.SongtableView reloadData];
    }

    
    
    else if (flag == 2 && arrayForPopularSong.count != 0){
            for (Songs* s in arrayForPopularSong) {
                [del.OnLineSongArray addObject:s];
            }
        [self.SongtableView reloadData];
    }
    
    
    //没有资源可用则直接进行网络请求
    else{
        [self PostRequestToGetSongID];
    }
    

}


//******************************************************************
//多层解析，得到能够访问音乐实体的URL

-(void)displaySongs{

    [self.Singers setTintColor:[UIColor blackColor]];
    
    if (flag == 1) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://tingapi.ting.baidu.com/v1/restserver/ting?method=baidu.ting.billboard.billList&type=1&format=json&offset=%d&size=%d",offsetCount,sizeCount]];
        [self.Newsong setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.PopularSong setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.searchSong setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    if (flag == 2){
         url = [NSURL URLWithString:[NSString stringWithFormat:@"http://tingapi.ting.baidu.com/v1/restserver/ting?method=baidu.ting.billboard.billList&type=2&format=json&offset=%d&size=%d",offsetCount,sizeCount]];
        [self.Newsong setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.PopularSong setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.searchSong setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
    if (flag == 3){
        if (self.SearchBar.text == nil) {
            UIAlertView* vie = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请先在搜索栏中输入要搜索的歌曲或歌名！" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [vie show];
        }
        
        
        
        NSString* u = [NSString stringWithFormat:@"http://tingapi.ting.baidu.com/v1/restserver/ting?method=baidu.ting.search.common&query=%@&page_size=%d&page_no=1&format=json&from=ios&version=2.1.1",self.SearchBar.text,sizeCount];
        NSString* encodedString =[u stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        url=[NSURL URLWithString:encodedString];
        
        
        [self.Newsong setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.PopularSong setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.searchSong setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
}
    
    
    
}


#pragma mark - 发送请求

-(void)PostRequestToGetSongID{

    ASIHTTPRequest* request = [[ASIHTTPRequest alloc] initWithURL:url];
    request.delegate = self;
    [request startAsynchronous];
    [request setTimeOutSeconds:60];
    
    //******************************************************************
    self.SongtableView.allowsMultipleSelectionDuringEditing = YES;
    [self updateButtonsToMatchTableState];
    //*****************************************************************


}

#pragma mark - request的代理方法
- (void)requestFinished:(ASIHTTPRequest *)request{
    
    
    [arrayForSearchsong removeAllObjects];
    NSData* data = [request responseData];
    NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSArray *arr=[dic objectForKey:@"song_list"];
    NSDictionary *page = [dic objectForKey:@"pages"];
    if (flag == 3) {
        if ([[page objectForKey:@"total"] isEqualToString:@"" ]) {
            UIAlertView* vie = [[UIAlertView alloc]initWithTitle:@"提示" message:@"很抱歉，未搜到" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [vie show];
        }
        else
        {
            for (NSDictionary *kk in arr) {
                Songs* m = [[Songs alloc]init];
                m.SongDetail =[kk objectForKey:@"author"];
                m.SongName = [kk objectForKey:@"title"];
                //消除em标签
                m.SongDetail = [self removeHTMLFocusLabel:m.SongDetail];
                m.SongName   = [self removeHTMLFocusLabel:m.SongName];
                m.song_id  = [[kk objectForKey:@"song_id"] intValue];
                NSString* urlString = [NSString stringWithFormat:@"http://ting.baidu.com/data/music/links?songIds=%d",m.song_id];
                NSURL* Url = [[NSURL alloc] initWithString:urlString];
                NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
                [request setURL:Url];
                NSData* receive = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:receive options:NSJSONReadingMutableContainers error:nil];
                NSDictionary *tn=[dic objectForKey:@"data"];
                NSArray *tn3=[tn objectForKey:@"songList"];
                for (NSDictionary *dd in tn3) {
                    m.SingerImageurl = [dd objectForKey:@"songPicSmall"];
                    m.SingerBigImageurl = [dd objectForKey:@"songPicRadio"];
                 }
                if ([arrayForSearchsong containsObject:m] == NO) {
                    [arrayForSearchsong addObject:m];
                }
        }
            
    }
        
        
}
    
    
    
    else{
        
        for (NSDictionary* k in arr) {
            Songs* n         =    [[Songs alloc]init];
            n.song_id        =    [[k objectForKey:@"song_id"] intValue];
            n.SongName       =    [k objectForKey:@"title"];
            n.SongDetail     =    [k objectForKey:@"artist_name"];
            n.SongDetail = [self removeHTMLFocusLabel:n.SongDetail];
            n.SongName   = [self removeHTMLFocusLabel:n.SongName];
            n.SingerImageurl =    [k objectForKey:@"pic_small"];
            n.SingerBigImageurl = [k objectForKey:@"pic_big"];
            if (flag == 1) {
                if ([arrayForNewSong containsObject:n] == NO) {
                    [arrayForNewSong addObject:n];
                }
            }
            
            if (flag == 2) {
                if ([arrayForPopularSong containsObject:n] == NO) {
                    [arrayForPopularSong addObject:n];
                }
            }

            
            
        }
        
    }
    
    
    
    [del.OnLineSongArray removeAllObjects];
    
    if (flag == 1) {
        for (Songs* so in arrayForNewSong) {
            [del.OnLineSongArray addObject:so];
        }
    }
    if (flag == 2) {
        for (Songs* so in arrayForPopularSong) {
            [del.OnLineSongArray addObject:so];
            
        }
        
    }
        if (flag == 3) {
            for (Songs* so in arrayForSearchsong) {
                [del.OnLineSongArray addObject:so];
            }
    }
    
    [self.SongtableView reloadData];
}



-(void)requestFailed:(ASIHTTPRequest*)request{
    UIAlertView* vie = [[UIAlertView alloc]initWithTitle:@"提示" message:@"网络歌曲请求失败，请检查网络" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [vie show];
}


//******************************************************************


#pragma mark - 切换到新歌榜
- (IBAction)ForNewSong:(id)sender {
    [self HidenSearchBar];
    flag = 1;
    [del.OnLineSongArray removeAllObjects];
    [self.SearchBar resignFirstResponder];

    if (arrayForNewSong.count != 0) {
        for (Songs* s in arrayForNewSong) {
            [del.OnLineSongArray addObject:s];
        }
        [self displaySongs];
        [self.SongtableView reloadData];
    }
    else{
        [self displaySongs];
        [self PostRequestToGetSongID];
    }

}




#pragma mark - 切换到流行歌榜
- (IBAction)ForPopularSong:(id)sender {
    [self HidenSearchBar];
    flag = 2;
    [del.OnLineSongArray removeAllObjects];
    [self.SearchBar resignFirstResponder];
    
    if (arrayForPopularSong.count != 0) {
        for (Songs* s in arrayForPopularSong) {
            [del.OnLineSongArray addObject:s];
        }
        [self displaySongs];
        [self.SongtableView reloadData];
    }
    else{
        [self displaySongs];
        [self PostRequestToGetSongID];
    }
    
 }



- (IBAction)searchSong:(id)sender {
    
    if (Judge == YES) {
        [self HidenSearchBar];
        [self.SearchBar resignFirstResponder];
    }
    
    else{
    self.SearchBar.delegate = self;
    self.SearchBar.placeholder=@"    请输入歌手或歌名   ";
    self.SearchBar.showsCancelButton=YES;
    self.SearchBar.autocorrectionType=UITextAutocorrectionTypeNo;
    self.SearchBar.autocapitalizationType=UITextAutocapitalizationTypeNone;
    self.SearchBar.keyboardType=UIKeyboardAppearanceDefault;
    [self DisPlaySearchBar];
    }
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    [self.SearchBar resignFirstResponder];

}



//***************************************************************
#pragma mark - tableview的代理方法

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [del.OnLineSongArray count];
}



- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
   mark = (int)indexPath.row;
   [self updateDownloadButtonTitle];
   [self saveUrlAndNameForSongs];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.SongtableView.editing == YES) {
       
        mark = (int)indexPath.row;
       
        // Update the delete button's title based on how many items are selected.
        [self saveUrlAndNameForSongs];
        [self updateButtonsToMatchTableState];
}
    
    else{
        mark = (int)indexPath.row;
         [self PlayOnline];
    
    }
    
}







- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"CustomCell";
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"CustomCell" owner:nil options:nil]lastObject];
    }

    Songs* n = [del.OnLineSongArray objectAtIndex:[indexPath row]];
 
    cell.SongName.text   = n.SongName;
    cell.SongDetail.text = n.SongDetail;
    [self loadImage:n.SingerImageurl andIndexPath:indexPath];
  
//########################################################################
    //显示歌曲下载情况
    NSString* path = [NSString stringWithFormat:@"%@/%@.mp3",del.LocalSongFilePath,n.SongName];
    if ([manager fileExistsAtPath:path]) {
        cell.ShowLrcStatement.text = @"已下载";
        cell.ShowLrcStatement.font = [UIFont systemFontOfSize:11];
        cell.ShowLrcStatement.textColor = [UIColor blueColor];
    }
    
    else{
        cell.ShowLrcStatement.hidden = YES;
        
    }
    
//########################################################################
   
    return cell;
    
}


//通过获取的URL地址得到歌手的小型图片
-(void)loadImage:(NSString*)urlPath andIndexPath:(NSIndexPath*)indexPath{
    //golobal dispatch queue.可以并发执行多个任务。但是执行任务的顺序是随机的
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL* Url = [NSURL URLWithString:urlPath];
        NSData* data = [[NSData alloc] initWithContentsOfURL:Url];
        UIImage* image = [[UIImage alloc]initWithData:data];
        if (image != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CustomCell* cell = (CustomCell*)[self.SongtableView cellForRowAtIndexPath:indexPath];
                cell.SingerImage.image = image;
                cell.SingerImage.layer.cornerRadius = 10;
                cell.SingerImage.layer.masksToBounds = YES;
                
                if (count < del.OnLineSongArray.count) {
                    [self.SongtableView reloadData];
                    count ++;
                }
            });
        }
        
    });
    
}



//***************************************************************

#pragma mark - 自定义方法解决标签问题

//用NSString自带的Seprated自截断方法

- (NSString *)removeHTMLFocusLabel:(NSString *)html{
    
    NSArray *components = [html componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    
    NSMutableArray *componentsToKeep = [NSMutableArray array];
    
    for (int i = 0; i < [components count]; i = i + 2) {
        
        [componentsToKeep addObject:[components objectAtIndex:i]];
        
    }
    
    NSString *plainText = [componentsToKeep componentsJoinedByString:@""];
    
    return plainText;
    
}






//***************************************************************


- (void)PlayOnline {
    [self songLink];

    if (del.OnlinePlayerVC == nil) {
        del.OnlinePlayerVC = [[EMPlayOnlineViewController alloc]initWithNibName:@"EMPlayOnlineViewController" bundle:nil];
    }
    del.OnlinePlayerVC.song = PlayingSong;
    [self.navigationController pushViewController:del.OnlinePlayerVC animated:YES];

   
 }


-(void)songLink{
    [songAndlrcLink removeAllObjects];
    Songs* song = [del.OnLineSongArray objectAtIndex:mark];
    int song_id =  [song song_id];
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
        
        song.SongLink = [nsdi objectForKey:@"songLink"];
        song.lrcLink  = [nsdi objectForKey:@"lrcLink"];
        PlayingSong = song;
    }
    
    
}



-(void)saveUrlAndNameForSongs{
    [self songLink];

    Songs* AnotherSong = [del.OnLineSongArray objectAtIndex:mark];

    if ([self.loadSongUrlAndName containsObject:AnotherSong]) {
        [self.loadSongUrlAndName removeObject:AnotherSong];
    }
    
    else{
    
        [self.loadSongUrlAndName addObject:AnotherSong];
    
    }
    

}


#pragma mark - 开始下载
- (void)BeginLoading {
    
    if (self.loadSongUrlAndName.count == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"请先选择您要下载的歌曲" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    
    
    
    else{
        
        
        for (Songs* s in self.loadSongUrlAndName) {
            if ([del.UrlAndNameForLoadSongs containsObject:s] == NO) {
                [del.UrlAndNameForLoadSongs addObject:s];

            }
        }
        
        
        if (del.loadVC == nil) {
            del.loadVC = [[EMLoadViewController alloc]initWithNibName:@"EMLoadViewController" bundle:nil];
        }
        
        
        [self.navigationController pushViewController:del.loadVC animated:YES];
        
    }
    
    
    
    
    
}




//******************************************************************************************

#pragma -mark searchBar代理方法
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	[self.SearchBar resignFirstResponder];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    flag = 3;
    [self.SearchBar resignFirstResponder];
    [self displaySongs];
    [self PostRequestToGetSongID];
    //####################################################
    //实现加载等待
        HUD = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:HUD];
        //如果设置此属性则当前的view置于后台
        HUD.labelText = @"请稍等";
        //显示对话框
        [HUD showAnimated:YES whileExecutingBlock:^{
            sleep(3);
        }completionBlock:^{
            [HUD removeFromSuperview];
            HUD = nil;
        }];
    
}
//************************************************************************************


#pragma mark - 搜索栏的弹出与隐藏方法实现

-(void)handleSwipe:(UISwipeGestureRecognizer *)sender{
    
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self DisPlaySearchBar];
    }
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        [self HidenSearchBar];
    }
}
-(void)DisPlaySearchBar{
    CGRect searcher = self.SearchBar.frame;
    CGRect tableview = self.SongtableView.frame;
    CGRect view = self.ViewForButtons.frame;


    searcher.origin.y  = 64.0f;
    view.origin.y  = 108.0f;
    tableview.origin.y = 168.0f;
   
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.SearchBar.frame = searcher;
        self.SongtableView.frame = tableview;
        self.ViewForButtons.frame = view;
        
    } completion:^(BOOL finished) {
        Judge = YES;
    }];
}

-(void)HidenSearchBar{
    CGRect searcher  = self.SearchBar.frame;
    CGRect tableview = self.SongtableView.frame;
    CGRect view = self.ViewForButtons.frame;

    searcher.origin.y  = -44.0f;
    view.origin.y = 65.0f;
    tableview.origin.y = 128.0f;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.SearchBar.frame = searcher;
        self.SongtableView.frame = tableview;
        self.ViewForButtons.frame = view;
    } completion:^(BOOL finished) {
        Judge = NO;
    }];
}


//******************************************************************************************

#pragma mark - 实现加载更多
-(void)setuprefresh{
    //    下拉刷新
    [self.SongtableView addHeaderWithTarget:self action:@selector(fresh)];
    //    上拉加载更多
    [self.SongtableView addFooterWithTarget:self action:@selector(loadmore)];
    self.SongtableView.headerPullToRefreshText = @"下拉刷新";
    self.SongtableView.headerRefreshingText = @"正在刷新";
    self.SongtableView.headerReleaseToRefreshText = @"松开即将刷新";
    self.SongtableView.footerRefreshingText = @"正在加载，请稍等";
}

-(void)fresh{
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.SongtableView reloadData];
        [self.SongtableView headerEndRefreshing];
    });
    
}
-(void)loadmore{
    
    
    [self.loadSongUrlAndName removeAllObjects];
    [self.SongtableView  setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];

    
    
    loadmoreTime ++;
    double delayInSeconds = 3.0;

    if (flag == 1) {
        if (arrayForNewSong.count != 0) {
            offsetCount += 15*loadmoreTime;
        }
    }
    
    if (flag == 2) {
        if (arrayForPopularSong.count != 0) {
            offsetCount += 15*loadmoreTime;
        }
    }
 
    
    [self displaySongs];
    [self PostRequestToGetSongID];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    [self.SongtableView reloadData];
    [self.SongtableView footerEndRefreshing];
    });
}





//******************************************************************************************

#pragma mark - 实现多行选择下载



-(void)updateButtonsToMatchTableState{
    if (self.SongtableView.editing == YES) {
        self.navigationItem.rightBarButtonItem = self.StartLoadButton;
        [self updateDownloadButtonTitle];
        self.navigationItem.leftBarButtonItem  = self.CancleButton;
    }

    else{
        
//        if (self.loadSongName.count > 0) {
//            self.StartLoadButton.enabled = YES;
//        }
//        else{
//            self.StartLoadButton.enabled = NO;
//        }
        self.navigationItem.rightBarButtonItem = self.LoadButton;
        self.navigationItem.leftBarButtonItem = nil;

        
    }
    

}



- (void)updateDownloadButtonTitle
{
    // Update the delete button's title, based on how many items are selected
    NSArray *selectedRows = [self.SongtableView indexPathsForSelectedRows];
    
    BOOL allItemsAreSelected = selectedRows.count == del.OnLineSongArray.count;
    BOOL noItemsAreSelected = selectedRows.count == 0;
    
    if (allItemsAreSelected || noItemsAreSelected)
    {
        self.StartLoadButton.title = NSLocalizedString(@"下载 (0)", @"");
    }
    else
    {
        NSString *titleFormatString =
        NSLocalizedString(@"下载 (%d)", @"Title for delete button with placeholder for number");
        self.StartLoadButton.title = [NSString stringWithFormat:titleFormatString, selectedRows.count];
    }
}






- (IBAction)Loading:(id)sender {
    [self.SongtableView setEditing:YES animated:YES];
//    [self.SongtableView ]
    [self updateButtonsToMatchTableState];
    [self.loadSongUrlAndName removeAllObjects];
    

}


- (IBAction)StartLoading:(id)sender {
    [self BeginLoading];
    [self.SongtableView  setEditing:NO animated:YES];
    self.navigationItem.rightBarButtonItem = self.LoadButton;
    self.navigationItem.leftBarButtonItem  = nil;
}


- (IBAction)Cancling:(id)sender {
    [self.SongtableView  setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];
    [self.loadSongUrlAndName removeAllObjects];

}




//******************************************************************************************

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



@end



















