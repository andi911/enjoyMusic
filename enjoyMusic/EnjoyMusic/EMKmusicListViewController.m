//
//  EMKmusicListViewController.m
//  EnjoyMusic
//
//  Created by administrator on 14-10-16.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import "EMKmusicListViewController.h"
#import "EMAppDelegate.h"
#import "EMKPLMViewController.h"
#import "Songs.h"

@interface EMKmusicListViewController ()
{
    EMAppDelegate *del;
    NSString *p;
    NSMutableArray* SongForDeleted;    //存储要删除的歌曲行


}

@end

@implementation EMKmusicListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    del = [UIApplication sharedApplication].delegate;
    UIImageView* vie = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"interface3.jpg"]];
    [self.view insertSubview:vie atIndex:0];
    self.tableView.backgroundColor=[UIColor clearColor];
    UILabel* label = [[UILabel alloc]init];
    self.tableView.tableFooterView = label;
    SongForDeleted = [[NSMutableArray alloc]init];

    [self getMyAACSong];
    
    self.tableView.editing = NO;
    [self updateButtonsToMatchTableState];

    
}

-(void)viewWillAppear:(BOOL)animated
{
    if (del.MyKSongArray == 0) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    self.tabBarController.tabBar.hidden = YES;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refresh) name:@"RefreshData" object:nil];
    
    
    
}

-(void)refresh{

    [self.tableView reloadData];

}




-(void)viewDidDisappear:(BOOL)animated{

    self.tabBarController.tabBar.hidden = YES;


}



-(void)getMyAACSong{

    [del.MyKSongArray removeAllObjects];
    NSFileManager *manager = [NSFileManager defaultManager];
    //取到文件里的项目名称
    NSArray *arr = [manager contentsOfDirectoryAtPath:del.UserKMusicFilePath error:nil];
    
    if (arr.count != 0) {
        for (int i = 0; i < arr.count; i ++) {
            
            NSString *str1 = [arr objectAtIndex:i];
            if ([[str1 pathExtension] isEqualToString:@"aac"]) {
                //去掉扩展名aac
                NSUInteger n = str1.length - 4;
                NSRange range = {0,n};
                str1 = [str1 substringWithRange:range];
                NSArray* array  = [str1 componentsSeparatedByString:@"--"];
                int id = [[array lastObject] intValue];
                if (id == del.currentUser.userId) {
                    Songs* song = [[Songs alloc]init];
                    song.SongName = str1;
                    [del.MyKSongArray addObject:song];
                }

                
            }
            
        }
    }
    
    if (del.MyKSongArray.count==0)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"K歌文件不存在，请前往K歌录制" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }



    

}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [del.MyKSongArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];

    Songs* song = [del.MyKSongArray objectAtIndex:[indexPath row]];
    NSString* name = song.SongName;
    NSArray* arr = [name componentsSeparatedByString:@"--"];
    NSString* s = [arr firstObject];
    cell.textLabel.text = s;
    cell.imageView.image=[UIImage imageNamed:@"music.jpg"];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    cell.backgroundColor = [UIColor clearColor];
    cell.imageView.image = [UIImage imageNamed:@"K歌图标.jpg"];
    cell.imageView.layer.cornerRadius = 10;
    cell.imageView.layer.masksToBounds = YES;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return 40;

}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{


    return [NSString stringWithFormat:@"                     当前用户: %@",del.currentUser.userName];

}





-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    //可编辑时
    if (self.tableView.editing == NO) {
        
        if (del.UserKSongPlayVC == nil) {
            del.UserKSongPlayVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayMyKSong"];
        }
        
        del.UserKSongPlayVC.KSong = del.MyKSongArray[indexPath.row];
        [self.navigationController pushViewController:del.UserKSongPlayVC animated:YES];
       

    }
    
    
    
    //不可编辑时
    
    else{
    
        [SongForDeleted addObject:indexPath];
        [self updateButtonsToMatchTableState];
    
    }
    



}




-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{

    [SongForDeleted removeObject:indexPath];
    [self updateButtonsToMatchTableState];
}







//***********************************多行编辑********************************************

- (IBAction)DeleteAction:(id)sender {
    
    NSFileManager* manager = [NSFileManager defaultManager];
    for (int i = 0; i < SongForDeleted.count; i++) {
        NSIndexPath* ind = [SongForDeleted objectAtIndex:i];
        Songs* s = [del.MyKSongArray objectAtIndex:ind.row ];
        
        if (s != del.UserKSongPlayVC.KSong) {
            NSString * fileName =[NSString stringWithFormat:@"%@/%@.mp3",del.UserKMusicFilePath,s.SongName];
            [manager removeItemAtPath:fileName error:nil];
            [del.MyKSongArray removeObject:s];
        }
        else{
            
            UIAlertView* v = [[UIAlertView alloc]initWithTitle:nil message:@"当前歌曲正在播放，无法删除" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [v show];
        }

        
        
        
        
        
        
        
        
    }
    
    
    self.tableView.editing = NO;
    [self updateButtonsToMatchTableState];
    [SongForDeleted removeAllObjects];
    [self.tableView reloadData];
    
    
    
    
    
}




- (IBAction)CancleAction:(id)sender {
    self.tableView.editing = NO;
    [self updateButtonsToMatchTableState];
}




- (IBAction)EditAction:(id)sender {
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.editing = YES;
    [self updateButtonsToMatchTableState];
}




-(void)updateButtonsToMatchTableState{
    if (self.tableView.editing == YES) {
        self.navigationItem.rightBarButtonItem = self.DeleteBUtton;
        self.navigationItem.leftBarButtonItem  = self.CanleButton;
        [self updateDeleteButtonTitle];
    }
    
    
    else{
        
        self.navigationItem.rightBarButtonItem = self.EditButton;
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    
}



- (void)updateDeleteButtonTitle
{
    // Update the delete button's title, based on how many items are selected
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    
    BOOL allItemsAreSelected = selectedRows.count == del.MyKSongArray.count;
    BOOL noItemsAreSelected = selectedRows.count == 0;
    
    if (allItemsAreSelected || noItemsAreSelected)
    {
        self.DeleteBUtton.title = NSLocalizedString(@"删除 (0)", @"");
    }
    else
    {
        NSString *titleFormatString =
        NSLocalizedString(@"删除 (%d)", @"Title for delete button with placeholder for number");
        self.DeleteBUtton.title = [NSString stringWithFormat:titleFormatString, selectedRows.count];
    }
}










- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end






