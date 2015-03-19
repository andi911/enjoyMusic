//
//  UserInfoViewController.m
//  EnjoyMusic
//
//  Created by Administrator on 14-10-29.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import "UserInfoViewController.h"
#import "EMAppDelegate.h"
#import "UserInfoHeadCell.h"
#import "UserInfoOtherCell.h"
#import "ASIFormDataRequest.h"
#import "SJAvatarBrowser.h"
#import "MProgressAlertView.h"
#define LoadUserHeadPath @"http://10.110.2.151:8888/EnjoyMusic/PHP/index.php/home/user/loaduserhead"
#define ChangeUserName @"http://10.110.2.151:8888/EnjoyMusic/PHP/index.php/home/user/changeusername"
#define ChangeUserSex @"http://10.110.2.151:8888/EnjoyMusic/PHP/index.php/home/user/changeusersex"
#define ChangeUserEmail @"http://10.110.2.151:8888/EnjoyMusic/PHP/index.php/home/user/changeuseremail"
#define ChangeUserTelphone @"http://10.110.2.151:8888/EnjoyMusic/PHP/index.php/home/user/changeusertelphone"
#define ChangeUserPassword @"http://10.110.2.151:8888/EnjoyMusic/PHP/index.php/home/user/changeuserpassword"

@interface UserInfoViewController ()
{
    EMAppDelegate *del;
     NSString *sex;
}
@property (nonatomic, retain) MProgressAlertView* progressAlertView;
@end

@implementation UserInfoViewController

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
    self.progressAlertView.delegate=self;
    // Do any additional setup after loading the view from its nib.
    
    del = [UIApplication sharedApplication].delegate;
    self.title = @"个人信息";
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableview reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 设置tableview的组数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

#pragma mark - 设置tableview的行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        return 3;
    }else {
        return 3;
    }
}

#pragma mark - 返回每一行显示的具体数据
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        if ([indexPath row] == 0) {
            static NSString *CellIdentifier = @"UserInfoHeadCell";
            UserInfoHeadCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"UserInfoHeadCell" owner:nil options:nil]lastObject];
            }
            if ([del.currentUser.userHeadLink isEqualToString:@""]) {
                cell.userHeadImage.image = [UIImage imageNamed:@"头像.png"];
                cell.userHeadImage.layer.cornerRadius = 30;
                cell.userHeadImage.layer.masksToBounds = YES;
            }else {
                NSString *string = [NSString stringWithFormat:@"http://10.110.2.151:8888/EnjoyMusic/PHP/Uploads/%@",del.currentUser.userHeadLink];
                NSURL *url = [NSURL URLWithString:string];
                
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                request.delegate = self;
                [request startSynchronous];
                NSData *data = [request responseData];
                cell.userHeadImage.image = [UIImage imageWithData:data];
                cell.userHeadImage.layer.cornerRadius = 30;
                cell.userHeadImage.layer.masksToBounds = YES;
            }
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] init];
            cell.userHeadImage.userInteractionEnabled = YES;
            [cell.userHeadImage addGestureRecognizer:tap];
            [tap addTarget:self action:@selector(tapClick:)];
            
            return cell;
        }
        else {
            static NSString *CellIdentifier = @"UserInfoOtherCell";
            UserInfoOtherCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"UserInfoOtherCell" owner:nil options:nil]lastObject];
            }
            if ([indexPath row] == 1) {
                cell.userProperty.text = @"用户名";
                cell.userPropertyValue.text = del.currentUser.userName;
            }else {
                cell.userProperty.text = @"性别";
                cell.userPropertyValue.text = del.currentUser.userSex;
            }
            return cell;
        }
    }
    else {
        static NSString *CellIdentifier = @"UserInfoOtherCell";
        UserInfoOtherCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"UserInfoOtherCell" owner:nil options:nil]lastObject];
        }
        if ([indexPath row] == 0) {
            cell.userProperty.text = @"邮箱";
            cell.userPropertyValue.text = del.currentUser.userEmail;
        }else if ([indexPath row] == 1) {
            cell.userProperty.text = @"手机号";
            cell.userPropertyValue.text = del.currentUser.userTelphone;
        }else {
            cell.userProperty.text = @"密码";
            cell.userPropertyValue.text = del.currentUser.userPassword;
        }
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0 && [indexPath row] == 0) {
        return 70;
    }
    else
        return 40;
}

#pragma mark - 选中
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0 && [indexPath row] == 0) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选择", nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        [actionSheet showInView:self.view];
    }
    if ([indexPath section] == 0 && [indexPath row] == 1) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"修改用户名" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认",nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 1000;
        alert.delegate = self;
        [alert show];
    }
    if ([indexPath section] == 0 && [indexPath row] == 2) {
        NSString *title=@"修改性别";
        self.progressAlertView = [[MProgressAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"男", @"女",  nil] ;
        
        self.progressAlertView.delegate = self;
        self.progressAlertView.tag=1001;
        [self.progressAlertView show];

    }
    if ([indexPath section] == 1 && [indexPath row] == 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"修改邮箱" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认",nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 1002;
        alert.delegate = self;
        [alert show];
    }
    if ([indexPath section] == 1 && [indexPath row] == 1) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"修改手机号" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认",nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 1003;
        alert.delegate = self;
        [alert show];
    }
    if ([indexPath section] == 1 && [indexPath row] == 2) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"修改密码" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认",nil];
        alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        alert.tag = 1004;
        alert.delegate = self;
        [alert show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1000) {
        if (buttonIndex == 1) {
            //修改用户名
            UITextField *field = [alertView textFieldAtIndex:0];
            NSURL *url = [NSURL URLWithString:ChangeUserName];
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
            [request setDelegate:self];
            [request setRequestMethod:@"POST"];
            [request addRequestHeader:@"Content-Type" value:@"binary/octet-stream"];
            
            [request setPostValue:[NSString stringWithFormat:@"%d",del.currentUser.userId] forKey:@"user_id"];
            [request setPostValue:field.text forKey:@"username"];
            
            [request startSynchronous];
            NSData *data = [request responseData];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSString *string = [dic objectForKey:@"result"];
            if ([string isEqualToString:@"1"]) {

                del.currentUser.userName = field.text;
                [[NSNotificationCenter defaultCenter]postNotificationName:@"RefreshData" object:nil];
             }
            [self viewWillAppear:YES];
        }
    }
    if (alertView.tag == 1001) {
        //修改性别
        NSURL *url = [NSURL URLWithString:ChangeUserSex];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setDelegate:self];
        [request setRequestMethod:@"POST"];
        [request addRequestHeader:@"Content-Type" value:@"binary/octet-stream"];
        if (buttonIndex==1) {
            sex=@"男";
        }
        else if (buttonIndex==2)
        {
            sex=@"女";
            
        }
        
        [request setPostValue:[NSString stringWithFormat:@"%d",del.currentUser.userId] forKey:@"user_id"];
        [request setPostValue:sex forKey:@"usersex"];
        
        [request startSynchronous];
        //获得请求的结果
        NSData *data = [request responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSString *string = [dic objectForKey:@"result"];
        if ([string isEqualToString:@"1"]) {
            del.currentUser.userSex =sex;
        }
        
        [self viewWillAppear:YES];
    }
    
    
    
    if (alertView.tag == 1002) {
        //修改e-mail
        if (buttonIndex == 1) {
            UITextField *field = [alertView textFieldAtIndex:0];
            NSURL *url = [NSURL URLWithString:ChangeUserEmail];
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
            [request setDelegate:self];
            [request setRequestMethod:@"POST"];
            [request addRequestHeader:@"Content-Type" value:@"binary/octet-stream"];
            
            [request setPostValue:[NSString stringWithFormat:@"%d",del.currentUser.userId] forKey:@"user_id"];
            [request setPostValue:field.text forKey:@"useremail"];
            
            [request startSynchronous];
            NSData *data = [request responseData];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSString *string = [dic objectForKey:@"result"];
            if ([string isEqualToString:@"1"]) {
                del.currentUser.userEmail = field.text;
            }
            [self viewWillAppear:YES];
        }
    }
    
    
    
    if (alertView.tag == 1003) {
        //修改手机号
        if (buttonIndex == 1) {
            UITextField *field = [alertView textFieldAtIndex:0];
            NSURL *url = [NSURL URLWithString:ChangeUserTelphone];
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
            [request setDelegate:self];
            [request setRequestMethod:@"POST"];
            [request addRequestHeader:@"Content-Type" value:@"binary/octet-stream"];
            
            [request setPostValue:[NSString stringWithFormat:@"%d",del.currentUser.userId] forKey:@"user_id"];
            [request setPostValue:field.text forKey:@"usertelphone"];
            
            [request startSynchronous];
            NSData *data = [request responseData];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSString *string = [dic objectForKey:@"result"];
            if ([string isEqualToString:@"1"]) {
                del.currentUser.userTelphone = field.text;
            }
            [self viewWillAppear:YES];
        }
    }
    
    
    if (alertView.tag == 1004) {
        //修改密码
        if (buttonIndex == 1) {
            UITextField *field = [alertView textFieldAtIndex:0];
            NSURL *url = [NSURL URLWithString:ChangeUserPassword];
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
            [request setDelegate:self];
            [request setRequestMethod:@"POST"];
            [request addRequestHeader:@"Content-Type" value:@"binary/octet-stream"];
            
            [request setPostValue:[NSString stringWithFormat:@"%d",del.currentUser.userId] forKey:@"user_id"];
            [request setPostValue:field.text forKey:@"userpassword"];
            
            [request startSynchronous];
            NSData *data = [request responseData];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSString *string = [dic objectForKey:@"result"];
            if ([string isEqualToString:@"1"]) {
                del.currentUser.userPassword = field.text;
            }
            [self viewWillAppear:YES];
        }
    }
}



-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;  //设置拍照后的图片可被编辑
    
    if (buttonIndex == 0) {   //呼出的菜单按钮点击后的响应
        
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
        {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:nil];
        }else
        {
            NSLog(@"模拟器中无法打开照相机,请在真机中使用");
        }
    }else if(buttonIndex == 1){
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"您取消了选择图片");
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSData *data;
    if (UIImagePNGRepresentation(image) == nil) {
        data = UIImageJPEGRepresentation(image, 1.0);
    }
    else {
        data = UIImagePNGRepresentation(image);
    }
    
    //图片保存路径
    NSURL *url = [NSURL URLWithString:LoadUserHeadPath];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type" value:@"binary/octet-stream"];
    
    [request setPostValue:[NSString stringWithFormat:@"%d",del.currentUser.userId] forKey:@"user_id"];
    [request addData:data withFileName:@"image.png" andContentType:@"image/png" forKey:@"file"];
    
    [request startAsynchronous];
    [request setDidFinishSelector:@selector(requestDidSuccess:)]; //当成功后会自动触发
    [request setDidFailSelector:@selector(requestDidFailed:)]; //如果失败会自动触发
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)tapClick:(UITapGestureRecognizer *)tap{
    [self imageViewClick:(UIImageView *)tap.view];
}

-(void)imageViewClick:(UIImageView *)imageView
{
    [SJAvatarBrowser showImage:imageView];
}

#pragma mark - ASIHTTPRequest异步请求委托方法
- (void)requestDidSuccess:(ASIFormDataRequest *)request
{
    //获得请求的结果
    NSData *data = [request responseData];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSString *string = [dic objectForKey:@"result"];
    NSString *string2 = [dic objectForKey:@"user"];
    if ([string isEqualToString:@"1"]) {
        NSLog(@"上传成功");
        del.currentUser.userHeadLink = string2;
    }
    [self.tableview reloadData];
}

#pragma mark - 请求失败
- (void)requestDidFailed:(ASIFormDataRequest *)request
{
    NSLog(@"上传失败!");
}

@end
