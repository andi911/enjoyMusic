//
//  EMLoadViewController.m
//  EnjoyMusic
//
//  Created by administrator on 14-9-25.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import "EMLoadViewController.h"
#import "EMAppDelegate.h"
#import "Songs.h"

#define DELETE_DONE 0
@interface EMLoadViewController ()
{
    EMAppDelegate *  del;
    
}

@end

@implementation EMLoadViewController

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
    
    
    self.title = @"进度显示";
    self.Loadlist.delegate   = self;
    self.Loadlist.dataSource = self;
    UILabel* label = [[UILabel alloc]init];
    self.Loadlist.tableFooterView = label;
    UIImageView* vie = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LoadInterface.jpg"]];
    [self.view insertSubview:vie atIndex:0 ];
    [self.Loadlist setBackgroundColor:[UIColor clearColor]];
    
    
}
//********************************************************

-(void)viewWillAppear:(BOOL)animated{
    [self.Loadlist reloadData];
    NSLog(@"%i",del.UrlAndNameForLoadSongs.count);
    
}





-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    return  del.UrlAndNameForLoadSongs.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    EMprogressCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSInteger i = indexPath.row;
    Songs* s = [del.UrlAndNameForLoadSongs objectAtIndex:i];
    NSString* m = [s.SongLink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if (cell == nil) {
        
        cell = [[EMprogressCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        [self.Loadlist setSeparatorStyle:UITableViewCellSeparatorStyleNone];//消除格子线
        [cell initWithdownloadURL:[NSURL URLWithString:m]];
        
        //找到代理执行相关函数以实现动态显示各下载进度
        [cell startWithDelegate:self];
        
        
        [self.Loadlist setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        cell.backgroundColor = [UIColor clearColor];
    }
    else if(cell.downloadURL == nil){
        [cell initWithdownloadURL:[NSURL URLWithString:m]];
        
        //找到代理执行相关函数以实现动态显示各下载进度
        [cell startWithDelegate:self];
    }
    
    
    
    return cell;
}


#pragma mark - progrocell
-(void)progressCellDownloadProgress:(float)progress Percentage:(NSInteger)percentage EMProgressCell:(EMprogressCell *)cell{
    NSIndexPath* indexPath = [self.Loadlist indexPathForCell:cell];
    
    Songs* song = [del.UrlAndNameForLoadSongs objectAtIndex:indexPath.row];
    NSString* s = song.SongName;
    
    
    cell.textLabel.text = [NSString stringWithFormat:@" %@   %ld%%",s,(long)percentage];
    
    cell.textLabel.font = [UIFont systemFontOfSize:11];
}



-(void)progressCellDownloadFinished:(NSData *)fileData EMProgressCell:(EMprogressCell *)cell{
    
    NSIndexPath* indexPath = [self.Loadlist indexPathForCell:cell];
    
    Songs* song = [del.UrlAndNameForLoadSongs objectAtIndex:indexPath.row];
    
    NSString* s = song.SongName;
    cell.textLabel.text = [NSString stringWithFormat:@"%@ 下载完成",s];
    cell.textLabel.font = [UIFont systemFontOfSize:11];
    
    
    if (cell.downloadData != nil) {
        //把下载的音乐文件自动保存至沙盒文件中
        NSString* path = [NSString stringWithFormat:@"%@/%@.mp3",del.LocalSongFilePath,s];
        [cell.downloadData writeToFile:path atomically:YES];
    }
    
    
    //已经下载完的歌曲存储到全局数组中
    [del.DownloadSuccessAccount addObject:song];
    
    
    [del.UrlAndNameForLoadSongs removeObject:song];
    [cell reset];
    [self.Loadlist deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
    //    [self.Loadlist reloadData];
    
    
    
}






-(void)progressCellDownloadFail:(NSError *)error EMProgressCell:(EMprogressCell *)cell{
    
    NSIndexPath* indexPath = [self.Loadlist indexPathForCell:cell];
    
    Songs* song = [del.UrlAndNameForLoadSongs objectAtIndex:indexPath.row];
    NSString* s = song.SongName;
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ 下载失败",s];
    cell.textLabel.font = [UIFont systemFontOfSize:11];
    
    [del.DownloadFailedAccount addObject:song];
    
    //删除下载失败的行
    [del.UrlAndNameForLoadSongs removeObjectAtIndex:indexPath.row];
    
    
    [self.Loadlist deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic ];
    
    //    [self.Loadlist reloadData];
    
}



//********************************************************



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end






