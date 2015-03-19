//
//  CleartheCacheViewController.m
//  EnjoyMusic
//
//  Created by administrator on 14-11-4.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import "CleartheCacheViewController.h"
#import "CustomCellForClearCache.h"
#import "EMAppDelegate.h"




@interface CleartheCacheViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>

{
    NSArray* array1;
    NSArray* array2;
    EMAppDelegate* del;
    float TotalSize ;
    UIImageView* _imageview;
    NSTimer* time;
}

@end

@implementation CleartheCacheViewController

static     int num = 0;


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
    
    UILabel* lab = [[UILabel alloc]init];
    self.tableview.tableFooterView = lab;
    
    del = [UIApplication sharedApplication].delegate;
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    array1 = @[@"本地音乐",@"K歌歌源",@"用户K歌",@"歌词文件 ",@"用户账号"];
    array2 = @[del.LocalSongFilePath,del.KMusicSourceFilePath,del.UserKMusicFilePath,del.SonglrcFilePath,del.UserFilePath];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refresh:) name:@"RefreshData" object:nil];
    
    
    //*****************************图片旋转*****************************
    
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(76, 137, 81, 82);
    
    UIImageView *imgview = [[UIImageView alloc]initWithFrame:CGRectMake(-42, -43, 81, 82)];
    imgview.image = [UIImage imageNamed:@"clearAll.png"];
    
    [btn addSubview:imgview];
    _imageview=imgview;
    [self.view addSubview:btn];

    //*****************************图片旋转*****************************

    
    
    
 }





-(void)viewWillAppear:(BOOL)animated{

    [self.tabBarController.tabBar setHidden:YES];
    [self.tableview reloadData];
    
    time = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(RotatingThemage) userInfo:Nil repeats:YES];

}

-(void)viewWillDisappear:(BOOL)animated{
    
    [self.tabBarController.tabBar setHidden:NO];
    [time invalidate];
}

-(void)refresh:(NSNotification *)notice
{
    TotalSize = 0;
    [self.tableview reloadData];
    
}






-(void)RotatingThemage{

    num ++;
    
    _imageview.transform = CGAffineTransformMakeRotation(M_PI/6*num);


}






-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 1;

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}




-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *CellIdentifier = @"CustomCellForClearCache";
    CustomCellForClearCache *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"CustomCellForClearCache" owner:nil options:nil]lastObject];
    }
    cell.tag =  indexPath.row + 100;
    cell.ItemNameLabel.text = array1[indexPath.row];
    long long size = [self folderSizeAtPath:array2[indexPath.row]];
    float KB = size;
    if (KB < 0.1) {
        KB *= 1024;
        cell.UnitLabel.text = @"KB";
    }

    TotalSize += size;
    cell.ItemSizeLabel.text = [NSString stringWithFormat:@"%1.1f",KB];
    
    cell.FolderImageView.image = [UIImage imageNamed:@"文件夹图标.png"];
    self.FileSizeLabel.text = [NSString stringWithFormat:@"文件共%0.1fM",TotalSize];

    return cell;

}



#pragma mark - 获取文件大小
- (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

- (float ) folderSizeAtPath:(NSString*) folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
}



- (IBAction)ClearAllFileOnce:(id)sender {
    
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"您确定删掉全部文件吗" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    self.view.alpha = 0.3;
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (buttonIndex == 1) {
        self.view.alpha = 1;
        for (NSString* filepath in array2) {
            
            NSArray *arr = [manager contentsOfDirectoryAtPath:filepath error:nil];
            for (NSString* p in arr) {
                NSString* path = [NSString stringWithFormat:@"%@/%@",filepath,p];
                [manager removeItemAtPath:path error:nil];
            }
            

        }
        TotalSize = 0;
        [self.tableview reloadData];
        
        [time invalidate];
        
        
    }
    
    
    
    if (buttonIndex == 0) {
        self.view.alpha = 1;

    }




}






- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end













