
//  UserRegisterViewController.m
//  EnjoyMusic
//
//  Created by Administrator on 14-10-28.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.


#import "UserRegisterViewController.h"
#import "ASIFormDataRequest.h"
#import "EMAppDelegate.h"
#import "User.h"

#define RegisterPath @"http://10.110.2.151:8888/EnjoyMusic/PHP/index.php/home/user/register"
#define CheckUsernamePath @"http://10.110.2.151:8888/EnjoyMusic/PHP/index.php/home/user/checkusername"

@interface UserRegisterViewController ()
{
    EMAppDelegate *del;
}
@end

@implementation UserRegisterViewController
@synthesize label1;
@synthesize label2;
@synthesize label3;
@synthesize label4;
@synthesize label5;
static bool isRegister = YES;

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
    
    self.title = @"用户注册";
    del = [UIApplication sharedApplication].delegate;
    
    self.username.delegate = self;
    self.userpassword.delegate = self;
    self.userpasswordResure.delegate = self;
    self.userEmail.delegate = self;
    self.userTelphone.delegate = self;
    
    self.username.clearButtonMode = UITextFieldViewModeAlways;
    self.userpassword.clearButtonMode = UITextFieldViewModeAlways;
    self.userpasswordResure.clearButtonMode = UITextFieldViewModeAlways;
    self.userEmail.clearButtonMode = UITextFieldViewModeAlways;
    self.userTelphone.clearButtonMode = UITextFieldViewModeAlways;
    
    self.userpassword.secureTextEntry = YES;
    self.userpasswordResure.secureTextEntry = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//开始编辑输入框的时候，软键盘出现，执行此事件
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;
    int offset = frame.origin.y + 112 - (self.view.frame.size.height - 216.0);  //键盘高度216
    
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

- (IBAction)action1:(id)sender {
    NSString *name = self.username.text;
    NSString *regex = @"^[0-9a-zA-Z_\u4E00-\u9FA5]{2,8}+$";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValid = [predicate evaluateWithObject:name];
    
    NSURL *url = [NSURL URLWithString:CheckUsernamePath];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type" value:@"binary/octet-stream"];
    
    [request setPostValue:self.username.text forKey:@"username"];
    
    [request startSynchronous];
    
    NSData *receive = [request responseData];
    if (receive != nil) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:receive options:NSJSONReadingMutableContainers error:nil];
        NSString *string = [dic objectForKey:@"status"];
        if ([string isEqualToString:@"0"]) {
            isRegister = YES;
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"对不起" message:@"该账号已被注册!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"重新输入", nil];
            [alert show];
        }
        else {
            isRegister = NO;
        }
    }

    
    if (isValid && isRegister == NO) {
        label1.text = @"✅";
    }
    else{
        label1.text = @"❌";
    }
}

- (IBAction)action2:(id)sender {
    NSString *passwd = self.userpassword.text;
    NSString *regex = @"^[a-zA-Z0-9]{6,20}+$";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValid = [predicate evaluateWithObject:passwd];
    if (isValid) {
        label2.text = @"✅";
    }
    else{
        label2.text = @"❌";
    }
}

- (IBAction)action3:(id)sender {
    BOOL isValid = NO;
    if ([self.userpassword.text isEqualToString:self.userpasswordResure.text]) {
        isValid = YES;
    }
    if (isValid && ![self.userpasswordResure.text isEqualToString:@""]) {
        label3.text = @"✅";
    }
    else{
        label3.text = @"❌";
    }
}

- (IBAction)action4:(id)sender {
    NSString *email = self.userEmail.text;
    NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValid = [predicate evaluateWithObject:email];
    if (isValid) {
        label4.text = @"✅";
    }
    else{
        label4.text = @"❌";
    }
}

- (IBAction)action5:(id)sender {
    NSString *telphone = self.userTelphone.text;
    NSString *regex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValid = [predicate evaluateWithObject:telphone];
    if (isValid) {
        label5.text = @"✅";
    }
    else{
        label5.text = @"❌";
    }
}

- (IBAction)close1:(id)sender {
    [self.username resignFirstResponder];
}

- (IBAction)close2:(id)sender {
    [self.userpassword resignFirstResponder];
}

- (IBAction)close3:(id)sender {
    [self.userpasswordResure resignFirstResponder];
}

- (IBAction)close4:(id)sender {
    [self.userEmail resignFirstResponder];
}

- (IBAction)close5:(id)sender {
    [self.userTelphone resignFirstResponder];
}

- (IBAction)closeAll:(id)sender {
    [self.username resignFirstResponder];
    [self.userpassword resignFirstResponder];
    [self.userpasswordResure resignFirstResponder];
    [self.userEmail resignFirstResponder];
    [self.userTelphone resignFirstResponder];
}

- (IBAction)registerAction:(id)sender {
    if([label1.text isEqualToString:@"✅"] && [label2.text isEqualToString:@"✅"] && [label3.text isEqualToString:@"✅"] && [label4.text isEqualToString:@"✅"] && [label5.text isEqualToString:@"✅"]){
        
        NSURL *url = [NSURL URLWithString:RegisterPath];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setDelegate:self];
        [request setRequestMethod:@"POST"];
        [request addRequestHeader:@"Content-Type" value:@"binary/octet-stream"];
        
        [request setPostValue:self.username.text forKey:@"username"];
        [request setPostValue:self.userpassword.text forKey:@"userpassword"];
        [request setPostValue:self.userEmail.text forKey:@"useremail"];
        [request setPostValue:self.userTelphone.text forKey:@"usertelphone"];
        
        [request startSynchronous];
        
        NSData *receive = [request responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:receive options:NSJSONReadingMutableContainers error:nil];
        NSString *string = [dic objectForKey:@"result"];
        if ([string isEqualToString:@"1"]) {
            NSLog(@"登录成功");
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
            
            
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:nil delegate:nil cancelButtonTitle:@"注册失败!" otherButtonTitles:nil,nil];
        [alert show];
    }
}
@end
