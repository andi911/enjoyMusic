//
//  LoginYesView.m
//  EnjoyMusic
//
//  Created by Administrator on 14-10-28.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import "LoginYesView.h"
#import "EMAppDelegate.h"
#import "UserInfoViewController.h"
#import "ASIHTTPRequest.h"

@interface LoginYesView()
{
    EMAppDelegate *del;
}
@end

@implementation LoginYesView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)awakeFromNib
{
    del = [UIApplication sharedApplication].delegate;
    
    if ([del.currentUser.userHeadLink isEqualToString:@""]) {
        [self.headButton setImage:[UIImage imageNamed:@"头像.png"] forState:UIControlStateNormal];
    }
    else {
        NSString *string = [NSString stringWithFormat:@"http://10.110.2.151:8888/EnjoyMusic/PHP/Uploads/%@",del.currentUser.userHeadLink];
        NSURL *url = [NSURL URLWithString:string];
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        request.delegate = self;
        [request startSynchronous];
        NSData *data = [request responseData];
        [self.headButton setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
        self.headButton.layer.cornerRadius = 30;
        self.headButton.layer.masksToBounds = YES;
    }
    
    self.nameLabel.text = del.currentUser.userName;
    if ([del.currentUser.userSex isEqualToString:@"男"]) {
        self.sexImageView.image = [UIImage imageNamed:@"master_my_normal@2x.png"];
    }
    else if ([del.currentUser.userSex isEqualToString:@"女"]){
        self.sexImageView.image = [UIImage imageNamed:@"master_my_selected@2x.png"];
    }
    else {
        self.sexImageView.image = [UIImage imageNamed:@""];
    }
}



- (IBAction)headAction:(id)sender {
    
    UserInfoViewController *userInfoView = [[UserInfoViewController alloc]initWithNibName:@"UserInfoViewController" bundle:nil];
    
    [self.theMoreViewController.navigationController pushViewController:userInfoView animated:YES];
}

@end





