
#import "EMSingerSongViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#include "Songs.h"
#import "CustomCell.h"
#import "EMAppDelegate.h"
#import "EMPlayOnlineViewController.h"
#import "MBProgressHUD.h"
#import "EMLoadViewController.h"
#import "MJRefresh.h"


@interface EMSingerSongViewController ()<UIActionSheetDelegate>
{
    NSString* Ting_uid;
    NSMutableArray *array;
    int count;
    EMAppDelegate * del;
    NSMutableArray* songAndlrcLink;     // 存储访问音乐实体及歌词
    int mark;                          //用以标记cell的行数
    MBProgressHUD *HUD;
    int j;                            //服务于加载更多
    Songs* PlayingSong;
    
    
}

@end

@implementation EMSingerSongViewController

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
    count = 0;
    del = [UIApplication sharedApplication].delegate;
    self.SongLIstTableview.dataSource = self;
    self.SongLIstTableview.delegate   = self;
    j = 15 ;
    
    
    self.loadSongUrlAndName  = [[NSMutableArray alloc]init];
    [del.OnLineSongArray removeAllObjects];
    
    UILabel* label = [[UILabel alloc]init];
    self.SongLIstTableview.tableFooterView = label;
    
    
    
    //接收参数
    Ting_uid = self.ting_uid;
    [self sendASynchronousRequest];
    
    [self setuprefresh];
    
    
}







#pragma mark - 发送异步请求
-(void)sendASynchronousRequest
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://tingapi.ting.baidu.com/v1/restserver/ting?method=baidu.ting.artist.getSongList&format=json&order=2&tinguid=%@&offset=0&limits=%d",Ting_uid,j]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.delegate = self;
    [request startAsynchronous];
    
    self.SongLIstTableview.allowsMultipleSelectionDuringEditing = NO;
    
    [self updateButtonsToMatchTableState];
    
    
    
}

#pragma mark - ASIHTTPRequest异步请求委托方法
-(void)requestFinished:(ASIHTTPRequest *)request
{
    [del.OnLineSongArray removeAllObjects];
    NSData* data = [request responseData];
    NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    
    NSArray* arr  = [dic objectForKey:@"songlist"];
    for (NSDictionary* k in arr) {
        Songs* n         =    [[Songs alloc]init];
        n.song_id        =    [[k objectForKey:@"song_id"] intValue];
        n.SongName       =    [k objectForKey:@"title"];
        n.SongDetail     =    [k objectForKey:@"author"];
        n.SingerImageurl =    [k objectForKey:@"pic_small"];
        n.SingerBigImageurl = [k objectForKey:@"pic_big"];
        
        [del.OnLineSongArray addObject:n];
        
    }
    [self.SongLIstTableview reloadData];
    
}



#pragma mark - 请求失败
-(void)requestFailed:(ASIHTTPRequest *)request
{
    UIAlertView* vie = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请求失败，请检查网络" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [vie show];
}




#pragma mark - tableview的代理方法

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  del.OnLineSongArray.count;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Update the delete button's title based on how many items are selected.
    [self updateDownloadButtonTitle];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.SongLIstTableview.editing == YES) {
        
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



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CustomCell";
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"CustomCell" owner:nil options:nil]lastObject];
    }
    Songs* n = [del.OnLineSongArray objectAtIndex:[indexPath row]];
    
    cell.SongName.text   = n.SongName;
    cell.SongName.font   = [UIFont systemFontOfSize:14];
    cell.SongDetail.text = n.SongDetail;
    cell.SongDetail.font = [UIFont systemFontOfSize:12];
    [self loadImage:n.SingerImageurl andIndexPath:indexPath];
    
    //##########################################################################
    //显示歌曲下载情况
    NSFileManager* manager = [NSFileManager defaultManager];
    NSString* path = [NSString stringWithFormat:@"%@/%@.mp3",del.LocalSongFilePath,n.SongName];
    if ([manager fileExistsAtPath:path]) {
        cell.ShowLrcStatement.text = @"已下载";
        cell.ShowLrcStatement.font = [UIFont systemFontOfSize:11];
        cell.ShowLrcStatement.textColor = [UIColor blueColor];
    }
    
    else{
        cell.ShowLrcStatement.hidden = YES;
        
    }
    //##########################################################################
    
    
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
                CustomCell* cell = (CustomCell*)[self.SongLIstTableview cellForRowAtIndexPath:indexPath];
                cell.SingerImage.image = image;
                cell.SingerImage.layer.cornerRadius = 10;
                cell.SingerImage.layer.masksToBounds = YES;
                if (count < del.OnLineSongArray.count) {
                    [self.SongLIstTableview reloadData];
                    count ++;
                }
            });
        }
        
    });
}


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

#pragma mark - 实现加载更多
-(void)setuprefresh{
    //    下拉刷新
    [self.SongLIstTableview addHeaderWithTarget:self action:@selector(fresh)];
    //    上拉加载更多
    [self.SongLIstTableview addFooterWithTarget:self action:@selector(loadmore)];
    self.SongLIstTableview.headerPullToRefreshText = @"下拉刷新";
    self.SongLIstTableview.headerRefreshingText = @"正在刷新";
    self.SongLIstTableview.headerReleaseToRefreshText = @"松开即将刷新";
    self.SongLIstTableview.footerRefreshingText = @"正在加载，请稍等";
}

-(void)fresh{
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.SongLIstTableview reloadData];
        [self.SongLIstTableview headerEndRefreshing];
    });
    
}
-(void)loadmore{
    
    [self.loadSongUrlAndName removeAllObjects];
    [self.SongLIstTableview  setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];

    
    
    
    double delayInSeconds = 3.0;
    j = j + 10;
    [self sendASynchronousRequest];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.self.SongLIstTableview reloadData];
        [self.self.SongLIstTableview footerEndRefreshing];
    });
    
}





//******************************************************************************************




#pragma mark - 实现批量下载
//**************************************************************************



-(void)updateButtonsToMatchTableState{
    if (self.SongLIstTableview.editing == YES) {
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
        self.navigationItem.leftBarButtonItem  = self.navigationItem.backBarButtonItem;
        
    }
    
    
}



- (void)updateDownloadButtonTitle{
    // Update the delete button's title, based on how many items are selected
    NSArray *selectedRows = [self.SongLIstTableview indexPathsForSelectedRows];
    
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






- (IBAction)Loading:(id)sender{
    [self.loadSongUrlAndName removeAllObjects];
    //设置多行编辑属性为 YES
    self.SongLIstTableview.allowsMultipleSelectionDuringEditing = YES;
    [self.SongLIstTableview setEditing:YES animated:YES];
    [self updateButtonsToMatchTableState];
}


- (IBAction)StartLoading:(id)sender{
    
    [self BeginLoading];
    [self.SongLIstTableview  setEditing:NO animated:YES];
    self.navigationItem.rightBarButtonItem = self.LoadButton;
    self.navigationItem.leftBarButtonItem = nil;
    
    
}


- (IBAction)Cancling:(id)sender{
    [self.SongLIstTableview  setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];
    
}




//**************************************************************************








- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}





@end









