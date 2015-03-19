//
//  EMKmusicListViewController.h
//  EnjoyMusic
//
//  Created by administrator on 14-10-16.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMKmusicListViewController : UITableViewController








@property (strong, nonatomic) IBOutlet UIBarButtonItem *EditButton;
- (IBAction)EditAction:(id)sender;


@property (strong, nonatomic) IBOutlet UIBarButtonItem *DeleteBUtton;

- (IBAction)DeleteAction:(id)sender;


@property (strong, nonatomic) IBOutlet UIBarButtonItem *CanleButton;

- (IBAction)CancleAction:(id)sender;







@end
