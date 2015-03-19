//
//  EMSingersViewController.h
//  EnjoyMusic
//
//  Created by administrator on 14-10-9.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMSingersViewController : UIViewController
<UITableViewDataSource,UITableViewDelegate>


@property (strong, nonatomic) IBOutlet UITableView *SingerListTableview;




@property (strong, nonatomic) IBOutlet UISegmentedControl *singerTypeSegmentButton;

- (IBAction)changeSingerType:(id)sender;






- (IBAction)Back:(id)sender;



@end
