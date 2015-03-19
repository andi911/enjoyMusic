//
//  SongListViewController.m
//  EnjoyMusic
//
//  Created by Administrator on 14-9-17.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import "SongListViewController.h"
#import "PlayLocalMusicViewController.h"
#import "EMAppDelegate.h"
#import "PlayLocalMusicViewController.h"
#import "Songs.h"
@interface SongListViewController ()
{
    EMAppDelegate *del;
    Songs* temp;
    NSMutableArray* SongForDeleted;    //存储要删除的歌曲行
}

@end

@implementation SongListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}


-(void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden=YES;
    
    
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    del = [UIApplication sharedApplication].delegate;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    SongForDeleted = [[NSMutableArray alloc]init];

    UIImageView* vie = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"interface3.jpg"]];
    [self.view insertSubview:vie atIndex:0];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    [self getSong];
    
    self.tableView.editing = NO;
    [self updateButtonsToMatchTableState];
    
    UILabel *label = [[UILabel alloc]init];
    self.tableView.tableFooterView = label;  //消除格子线

    
    
}


-(void)getSong{

    NSFileManager *manager = [NSFileManager defaultManager];
    
    //取到文件里的项目名称
    NSArray *arr = [manager contentsOfDirectoryAtPath:del.LocalSongFilePath error:nil];
    [del.LocalSongArray removeAllObjects];
    if (arr.count != 0) {
        for (int i = 0; i < arr.count; i ++) {
            NSString *str1 = [arr objectAtIndex:i];
            //去掉后缀名 .mp3
            NSUInteger n = str1.length - 4;
            NSRange range = {0,n};
            str1 = [str1 substringWithRange:range];
            Songs* song = [[Songs alloc]init];
            song.SongName = str1;
            [del.LocalSongArray addObject:song];
        }
    }




}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
     return [del.LocalSongArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customCellthree"];
    cell.tag = [indexPath row] + 100;
    Songs* s = [del.LocalSongArray objectAtIndex:[indexPath row]];
    cell.textLabel.text = s.SongName;
    cell.imageView.image=[UIImage imageNamed:@"本地音乐图标.png"];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return 40;

}


- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (del.LocalSongArray.count==0) {
        self.navigationItem.rightBarButtonItem=nil;
    }
    
    
    NSString* number = [NSString stringWithFormat:@"                         本地音乐有%d首",del.LocalSongArray.count];
    return number;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
   //向播放页面跳转
    if (self.tableView.editing == NO) {
        
        
        if (del.LocalPlayerVC == nil) {
            del.LocalPlayerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LocalMusticVC"];
        }
        
        temp = [del.LocalSongArray objectAtIndex:indexPath.row];
        
        del.LocalPlayerVC.song = temp;
        
        [self.navigationController pushViewController:del.LocalPlayerVC animated:YES];
        

    }
    
    
 
 //选择删除
    else{
        
         Songs* s = [del.LocalSongArray objectAtIndex:indexPath.row];
         [SongForDeleted addObject:s];
         [self updateButtonsToMatchTableState];
    }

    
    
    

}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    Songs* s = [del.LocalSongArray objectAtIndex:indexPath.row];
    [SongForDeleted removeObject:s];
    [self updateButtonsToMatchTableState];

}





//*************************   本地删除    **************************




#pragma mark 删除操作
//实现了此方法向左滑动就会显示删除按钮
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
     editingStyle = UITableViewCellEditingStyleDelete;

    NSFileManager *fileManager = [NSFileManager defaultManager];
    Songs* s = [del.LocalSongArray objectAtIndex:indexPath.row];
    if (s != del.LocalPlayerVC.song) {
        NSString * fileName =[NSString stringWithFormat:@"%@/%@.mp3",del.LocalSongFilePath,s.SongName];
        [fileManager removeItemAtPath:fileName error:nil];
        [del.LocalSongArray removeObject:s];
    }
    else{
        
        UIAlertView* v = [[UIAlertView alloc]initWithTitle:nil message:@"当前歌曲正在播放，无法删除" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [v show];
    }
    
    [self.tableView reloadData];
    
    
}




#pragma mark - 多行删除

//********************************************************





- (IBAction)CancleAction:(id)sender {
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.editing = NO;
    [self updateButtonsToMatchTableState];

}



- (IBAction)DeleteAction:(id)sender {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (SongForDeleted.count > 0) {
        
//    for (int i = 0; i < SongForDeleted.count; i++) {
//        
//        NSIndexPath* pa = [SongForDeleted objectAtIndex:i];
//        long int mark = [pa row] ;
//        Songs* s = del.LocalSongArray[mark];
//        if (s != del.LocalPlayerVC.song) {
//            NSString * fileName =[NSString stringWithFormat:@"%@/%@.mp3",del.LocalSongFilePath,s.SongName];
//            [fileManager removeItemAtPath:fileName error:nil];
//            [del.LocalSongArray removeObject:s];
//        }
//        else{
//        
//            UIAlertView* v = [[UIAlertView alloc]initWithTitle:nil message:@"当前歌曲正在播放，无法删除" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//            [v show];
//        }
//        
//        
//        
//    }
        
        for (Songs* s in SongForDeleted) {
            
             
                    if (s != del.LocalPlayerVC.song) {
                       NSString * fileName =[NSString stringWithFormat:@"%@/%@.mp3",del.LocalSongFilePath,s.SongName];
                        [fileManager removeItemAtPath:fileName error:nil];
                        [del.LocalSongArray removeObject:s];
                    }
                    else{
            
                        UIAlertView* v = [[UIAlertView alloc]initWithTitle:nil message:@"当前歌曲正在播放，无法删除" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [v show];
                    }

            
        }
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
    self.tableView.editing = NO;
    [self updateButtonsToMatchTableState];

    [self.tableView reloadData];
    
    }
    
    
    
}



- (IBAction)EditAction:(id)sender {
    [SongForDeleted removeAllObjects];
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.editing = YES;
    [self updateButtonsToMatchTableState];

    
}



-(void)updateButtonsToMatchTableState{
    if (self.tableView.editing == YES) {
        self.navigationItem.rightBarButtonItem = self.DeleteItemButton;
        self.navigationItem.leftBarButtonItem  = self.CancleItemButton;
        [self updateDeleteButtonTitle];
    }
    
    
    else{

        self.navigationItem.rightBarButtonItem = self.EditItemButton;
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    
}



- (void)updateDeleteButtonTitle
{
    // Update the delete button's title, based on how many items are selected
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    
    BOOL allItemsAreSelected = selectedRows.count == del.LocalSongArray.count;
    BOOL noItemsAreSelected = selectedRows.count == 0;
    
    if (allItemsAreSelected || noItemsAreSelected)
    {
        self.DeleteItemButton.title = NSLocalizedString(@"删除 (0)", @"");
    }
    else
    {
        NSString *titleFormatString =
        NSLocalizedString(@"删除 (%d)", @"Title for delete button with placeholder for number");
        self.DeleteItemButton.title = [NSString stringWithFormat:titleFormatString, selectedRows.count];
    }
}












//********************************************************



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}







@end


























