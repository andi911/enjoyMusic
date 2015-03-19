//
//  UserRegisterViewController.h
//  EnjoyMusic
//
//  Created by Administrator on 14-10-28.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserRegisterViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *userpassword;
@property (weak, nonatomic) IBOutlet UITextField *userpasswordResure;
@property (weak, nonatomic) IBOutlet UITextField *userEmail;
@property (weak, nonatomic) IBOutlet UITextField *userTelphone;


- (IBAction)action1:(id)sender;
- (IBAction)action2:(id)sender;
- (IBAction)action3:(id)sender;
- (IBAction)action4:(id)sender;
- (IBAction)action5:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *label4;
@property (weak, nonatomic) IBOutlet UILabel *label5;

- (IBAction)close1:(id)sender;
- (IBAction)close2:(id)sender;
- (IBAction)close3:(id)sender;
- (IBAction)close4:(id)sender;
- (IBAction)close5:(id)sender;

- (IBAction)closeAll:(id)sender;

- (IBAction)registerAction:(id)sender;

@end
