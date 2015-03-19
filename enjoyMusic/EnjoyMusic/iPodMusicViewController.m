//
//  iPodMusicViewController.m
//  EnjoyMusic
//
//  Created by Administrator on 14-10-13.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import "iPodMusicViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "PlayiPodMusicViewController.h"
#import "EMAppDelegate.h"

@interface iPodMusicViewController ()
{
    EMAppDelegate* del;
    
}

@end

@implementation iPodMusicViewController

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
    
    self.title = @"iPod歌曲";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    del = [UIApplication sharedApplication].delegate;
    
    [del.iPodSongArray removeAllObjects];
  //从媒体库读取iPod歌曲，并存储到全局数组中
    NSArray *media_arr = [[MPMediaQuery playlistsQuery] items];
    
    for (MPMediaItem *item in media_arr) {
        
        [del.iPodSongArray addObject:item];
        
    }
    
    
    
    UILabel* label = [[UILabel alloc]init];
    self.tableView.tableFooterView = label;
    
    
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [del.iPodSongArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ipodMusicCell"];
    MPMediaItem* it = [del.iPodSongArray objectAtIndex:[indexPath row]];
    cell.textLabel.text = [it valueForProperty:MPMediaItemPropertyAlbumTitle];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{


    if (del.iPodPlayerVC == nil) {
        del.iPodPlayerVC = [[PlayiPodMusicViewController alloc]initWithNibName:@"PlayiPodMusicViewController" bundle:nil];
    }
    MPMediaItem* it = [del.iPodSongArray objectAtIndex:indexPath.row];
    del.iPodPlayerVC.item = it;
    [self.navigationController pushViewController:del.iPodPlayerVC animated:YES];


}







- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
