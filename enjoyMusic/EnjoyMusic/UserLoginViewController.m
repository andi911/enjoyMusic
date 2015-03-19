//
//  UserLoginViewController.m
//  EnjoyMusic
//
//  Created by Administrator on 14-10-28.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import "UserLoginViewController.h"
#import "UserRegisterViewController.h"
#import "ASIFormDataRequest.h"
#import "EMAppDelegate.h"
#import "User.h"

#define LoginPath @"http://10.110.2.151:8888/EnjoyMusic/PHP/index.php/home/user/login"

@interface UserLoginViewController ()

{
    EMAppDelegate *del;
    BOOL SaveOrNot;
    NSString* anotherUserName;
    NSTimer* time;
}

@end

@implementation UserLoginViewController

static int mark = 0;

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
    // Do any additional setup after loading the view from its nib.
    [self.tabBarController.tabBar setHidden:YES];
    
    self.title = @"用户登录";
    
    del = [UIApplication sharedApplication].delegate;
    
    self.usernameTextField.delegate = self;
    self.userpasswordTextField.delegate = self;
    
    self.usernameTextField.clearButtonMode = UITextFieldViewModeAlways;
    self.userpasswordTextField.clearButtonMode = UITextFieldViewModeAlways;
    
    self.userpasswordTextField.secureTextEntry = YES;
    
    self.usernameTextField.autocorrectionType = UITextAutocorrectionTypeYes;
    self.userpasswordTextField.autocorrectionType = UITextAutocorrectionTypeYes;
    
    
    
    
    
    //*****************************用户名本地化保存后登陆*****************************
    
    NSMutableDictionary* infolist = [[[NSMutableDictionary alloc]initWithContentsOfFile:del.UserFilePath] mutableCopy];
    NSArray* keys = [infolist allKeys];
    NSString* name = [keys lastObject];
    NSRange r = {0,8};
    NSString* p ;
    if (name.length > 8) {
        p = [name substringWithRange:r];
    }
    if ([p isEqualToString:@"SaveCode"]) {
        int leng = name.length - 8;
        NSRange ra = {8,leng};
        NSString* ns = [name substringWithRange:ra];
        self.usernameTextField.text = ns;
        anotherUserName = ns;
        self.userpasswordTextField.text = [infolist objectForKey:name];
        [self.SaveCodeOrNotButton setTitle:@"✅" forState:UIControlStateNormal];
        
        mark += 1;
    }
    
    else{
    
        self.usernameTextField.text = name;
        self.userpasswordTextField.text = nil;
     }
    
    
  time = [NSTimer scheduledTimerWithTimeInterval:0.8f target:self selector:@selector(WhetherUserChange) userInfo:nil repeats:YES];
    
    //************************************************************************

    
}


-(void)WhetherUserChange{

    if ([self.usernameTextField.text isEqualToString:anotherUserName] == NO) {
        self.userpasswordTextField.text = nil;
        [time invalidate];
    }
}



//开始编辑输入框的时候，软键盘出现，执行此事件
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;
    int offset = frame.origin.y + 32 - (self.view.frame.size.height - 216.0);  //键盘高度216
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if (offset  > 0) {
        
        NSTimeInterval animationDuration = 0.3f;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        
        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
        [UIView commitAnimations];
    }
}

//当用户按下return键或者按回车键，keyboard消失
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

//输入框编辑完成以后，将视图恢复到原始状态
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (IBAction)login:(id)sender {
    NSString *url = [NSString stringWithFormat:LoginPath];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    
    [request setPostValue:self.usernameTextField.text forKey:@"username"];
    [request setPostValue:self.userpasswordTextField.text forKey:@"userpassword"];
    [request startSynchronous];
    
    NSData *receive = [request responseData];
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:receive options:NSJSONReadingMutableContainers error:nil];
    NSString *string = [dic objectForKey:@"result"];
    if ([string isEqualToString:@"1"]) {
        del.IsLogin = YES;
        
        NSArray *arr = [dic objectForKey:@"user"];
        NSDictionary *dic2 = [arr objectAtIndex:0];
        User *user = [[User alloc]init];
        user.userId = [[dic2 objectForKey:@"user_id"] intValue];
        user.userName = [dic2 objectForKey:@"user_name"];
        user.userSex = [dic2 objectForKey:@"user_sex"];
        user.userEmail = [dic2 objectForKey:@"user_email"];
        user.userTelphone = [dic2 objectForKey:@"user_telphone"];
        user.userHeadLink = [dic2 objectForKey:@"user_head"];
        del.currentUser = user;
        
        
        //*****************************用户名本地化保存*****************************
        
        NSMutableDictionary* userFilePlist = [[NSMutableDictionary alloc]init];
        
        if (mark % 2 == 1) {
            NSString* markName = [NSString stringWithFormat:@"SaveCode%@",user.userName];
            [userFilePlist setObject:self.userpasswordTextField.text forKey:markName];
        }
        
        else{
            [userFilePlist setObject:self.userpasswordTextField.text forKey:user.userName];
        }

        [userFilePlist writeToFile:del.UserFilePath atomically:YES];

        
        
        //************************************************************************

        
        
        
        [self.navigationController popToRootViewControllerAnimated:YES];

    }
    
    
    else{
        UIAlertView* view = [[UIAlertView alloc]initWithTitle:@"登录失败" message:@"请检查用户名或密码是否正确 "delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [view show];
    
    }


}

- (IBAction)close1:(id)sender {
    [self.usernameTextField resignFirstResponder];
}

- (IBAction)close2:(id)sender {
    [self.userpasswordTextField resignFirstResponder];
}

- (IBAction)closeAll:(id)sender {
    [self.usernameTextField resignFirstResponder];
    [self.userpasswordTextField resignFirstResponder];
}

- (IBAction)RegisterForNewUser:(id)sender {
    UserRegisterViewController *userRegisterView = [[UserRegisterViewController alloc]initWithNibName:@"UserRegisterViewController" bundle:nil];
    [self.navigationController pushViewController:userRegisterView animated:YES];

}






- (IBAction)SaveCodeOrNotAction:(id)sender {
    
    mark ++;
    if (mark % 2 == 1) {
        [self.SaveCodeOrNotButton setTitle:@"✅" forState:UIControlStateNormal];
    }
    else{
        [self.SaveCodeOrNotButton setTitle: @" " forState:UIControlStateNormal];

    
    }
    
}
















- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end




