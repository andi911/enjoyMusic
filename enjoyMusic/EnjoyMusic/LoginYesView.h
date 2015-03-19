//
//  LoginYesView.h
//  EnjoyMusic
//
//  Created by administrator on 14-10-30.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TheMoreViewController.h"




@interface LoginYesView : UIView



@property (weak, nonatomic) IBOutlet UIButton *headButton;

- (IBAction)headAction:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *sexImageView;

@property (strong, nonatomic) TheMoreViewController *theMoreViewController;














@end
