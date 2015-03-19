//
//  TimeClosureViewController.h
//  EnjoyMusic
//
//  Created by administrator on 14-10-30.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeClosureViewController : UIViewController




@property (strong, nonatomic) IBOutlet UIPickerView *TimeClosurePickerView;


@property (strong, nonatomic) IBOutlet UILabel *IntengerForHourLael;

@property (strong, nonatomic) IBOutlet UILabel *IntengerForMinLabel;

- (IBAction)StartTiming:(id)sender;




@end
