//
//  LoginNotView.m
//  EnjoyMusic
//
//  Created by administrator on 14-10-30.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import "LoginNotView.h"
#import "UserLoginViewController.h"

@implementation LoginNotView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



/*
 
 awakeFromNib
 
 当.nib文件被加载的时候，会发送一个awakeFromNib的消息到.nib文件中的每个对象，每个对象都可以定义自己的 awakeFromNib函数来响应这个消息，执行一些必要的操作。也就是说通过nib文件创建view对象是执行awakeFromNib 。
 
 viewDidLoad
 
 当view对象被加载到内存是就会执行viewDidLoad，所以不管通过nib文件还是代码的方式创建对象都会执行viewDidLoad。awakeFromNib和viewDidLoad的区别
 
 */




-(void)awakeFromNib{


    self.imageView.image = [UIImage imageNamed:@"left_bar_mine_n.png"];
    self.imageView.layer.cornerRadius = 10;
    self.imageView.layer.masksToBounds = YES;


}


- (IBAction)loginAction:(id)sender {
    UserLoginViewController *userLoginView = [[UserLoginViewController alloc]initWithNibName:@"UserLoginViewController" bundle:nil];
    
    [self.theMoreViewController.navigationController pushViewController:userLoginView animated:YES];
    
}





@end








