//
//  TheMoreViewController.m
//  EnjoyMusic
//
//  Created by Administrator on 14-10-13.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import "TheMoreViewController.h"
#import "EMAppDelegate.h"
#import "LoginNotView.h"
#import "LoginYesView.h"
#import "UserLogOffCell.h"
#import "TimeClosureViewController.h"
#import "EMAboutSoftViewController.h"
#import "CleartheCacheViewController.h"

@interface TheMoreViewController ()
{
    EMAppDelegate *del;
    NSMutableArray *group;
}
@end

@implementation TheMoreViewController

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
	// Do any additional setup after loading the view.
    
    del = [UIApplication sharedApplication].delegate;
    group = [[NSMutableArray alloc]init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@""]];
    [self.view insertSubview:imageView atIndex:0];
    
    
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:NO];
    if (del.IsLogin == NO) {
        [self initData];
        LoginNotView *loginNotView = [[[NSBundle mainBundle]loadNibNamed:@"LoginNotView" owner:nil options:nil]lastObject];
        loginNotView.theMoreViewController = self;
        self.tableView.tableHeaderView = loginNotView;
        
    }
    else {
        [self initData2];
        LoginYesView *loginYesView = [[[NSBundle mainBundle]loadNibNamed:@"LoginYesView" owner:nil options:nil]lastObject];
        loginYesView.theMoreViewController = self;
        self.tableView.tableHeaderView = loginYesView;
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 初始化数据
-(void)initData
{
    [group removeAllObjects];
    
    NSString *string1 = @"版本更新";
    NSMutableArray *arr1 = [NSMutableArray arrayWithObjects:string1, nil];
    [group addObject:arr1];
    
    NSString *string2 = @"文件清理";
    NSString *string3 = @"定时关闭";
    NSString *string4 = @"关于乐享音乐";
    NSMutableArray *arr2 = [NSMutableArray arrayWithObjects:string2, string3, string4, nil];
    [group addObject:arr2];
    [self.tableView reloadData];
}

-(void)initData2
{
    [group removeAllObjects];
    
    NSString *string1 = @"版本更新";
    NSMutableArray *arr1 = [NSMutableArray arrayWithObjects:string1, nil];
    [group addObject:arr1];
    
    NSString *string2 = @"设置";
    NSString *string3 = @"定时关闭";
    NSString *string4 = @"关于乐享音乐";
    NSMutableArray *arr2 = [NSMutableArray arrayWithObjects:string2, string3, string4, nil];
    [group addObject:arr2];
    
    NSString *string5 = @"";
    NSMutableArray *arr3 = [NSMutableArray arrayWithObjects:string5, nil];
    [group addObject:arr3];
    [self.tableView reloadData];
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
    
    
    if ([indexPath section] == 0) {
        UITableViewCell *cell;
        NSMutableArray *arr = group[indexPath.section];
        NSString *string = arr[indexPath.row];
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //设置分类
        cell.textLabel.text = string;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        
        return cell;
    }
    else if ([indexPath section] == 1) {
        UITableViewCell *cell;
        NSMutableArray *arr = group[indexPath.section];
        NSString *string = arr[indexPath.row];
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = string;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        
        return cell;
    }
    else if ([indexPath section] == 2) {
        static NSString *CellIdentifier = @"UserLogOffCell";
        UserLogOffCell *logOffCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (logOffCell == nil) {
            logOffCell = [[[NSBundle mainBundle]loadNibNamed:@"UserLogOffCell" owner:nil options:nil]lastObject];
        }
        
        return logOffCell;
    }
    return 0;
}

#pragma mark - 选中
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([indexPath section] == 0 && [indexPath row] == 0) {
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"您好" message:@"当前版本已经是最新版本。" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        
    }
    if ([indexPath section] == 1 && [indexPath row] == 0) {
        //清除缓存
        CleartheCacheViewController* v = [[CleartheCacheViewController alloc]initWithNibName:@"CleartheCacheViewController" bundle:nil];
        [self.navigationController pushViewController:v animated:YES];
        
        
    }
    if ([indexPath section] == 1 && [indexPath row] == 1) {
        //定时关闭
        TimeClosureViewController* v = [[TimeClosureViewController alloc]initWithNibName:@"TimeClosureViewController" bundle:nil];
        [self.navigationController pushViewController:v animated:YES];
    }
    if ([indexPath section] == 1 && [indexPath row] == 2) {
        //关于软件
        EMAboutSoftViewController* v = [[EMAboutSoftViewController alloc]initWithNibName:@"EMAboutSoftViewController" bundle:nil];
        [self.navigationController pushViewController:v animated:YES];
        
    }
    if ([indexPath section] == 2 && [indexPath row] == 0) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"退出后不会删除任何历史数据。" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出登录" otherButtonTitles:nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        [actionSheet showInView:self.view];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        del.currentUser = nil;
        del.IsLogin = NO;
        [self viewWillAppear:YES];
    }
}
@end








