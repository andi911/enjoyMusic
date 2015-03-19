//
//  EMAboutSoftViewController.m
//  EnjoyMusic
//
//  Created by administrator on 14-11-3.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import "EMAboutSoftViewController.h"

@interface EMAboutSoftViewController ()

@end

@implementation EMAboutSoftViewController

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

    self.SoftDetailTextview.textColor = [UIColor blackColor];
    self.SoftDetailTextview.font = [UIFont fontWithName:@"Arial" size:15];
 

    self.SoftDetailTextview.scrollEnabled = YES;
    self.SoftDetailTextview.editable = NO;
    self.SoftDetailTextview.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    
    
    self.SoftDetailTextview.text = @"       历时一个月左右，《乐享音乐》终于面世了，在此我们深感欣慰！《乐享音乐》是由蒋磊、成良雨、汪佳贵三人组成的团队开发的一款多功能IOS操作系统系列电子产品音乐播放器， 包含了本地歌曲播放，网络歌曲播放和下载，K歌，iPod歌曲自动识别，歌词同步，登陆分享K歌到微博圈等等功能，应该来说还是比较完善的。歌曲源部分源于百度，我们自己搭建的服务器也存储了一些数据以供使用。从开发之初到现在，团队经历了不少挫折，毕竟学习OC和IOS前后时间才一个多月，但是在我们的坚持和努力下，最终目标还是基本上达到了。开发过程也让我们懂得了合作、自学、态度的重要性，也体会到了不经历风雨哪来彩虹的道理。如今，在ios开发领域，我们只是森林中的一花一草，不过我们坚信，带着这种虔诚好学的态度，我们终能长成一棵大树。由于水平有限，《乐享音乐》免不了有很多不足之处，甚至是Bug，我们真诚希望朋友们能及时指正，以便我们加以改进！";
    
    

}



-(void)viewWillAppear:(BOOL)animated{

    [self.tabBarController.tabBar setHidden:YES];


}


-(void)viewWillDisappear:(BOOL)animated{


    [self.tabBarController.tabBar setHidden:NO];

}





































- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end


















