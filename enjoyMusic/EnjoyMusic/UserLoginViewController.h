//
//  UserLoginViewController.h
//  EnjoyMusic
//
//  Created by Administrator on 14-10-28.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserLoginViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *userpasswordTextField;

- (IBAction)login:(id)sender;

- (IBAction)close1:(id)sender;
- (IBAction)close2:(id)sender;

- (IBAction)closeAll:(id)sender;

- (IBAction)RegisterForNewUser:(id)sender;






- (IBAction)SaveCodeOrNotAction:(id)sender;


@property (strong, nonatomic) IBOutlet UIButton *SaveCodeOrNotButton;





@end
