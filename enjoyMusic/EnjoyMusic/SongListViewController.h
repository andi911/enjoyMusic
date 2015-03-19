//
//  SongListViewController.h
//  EnjoyMusic
//
//  Created by Administrator on 14-9-17.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>


@property (weak, nonatomic) IBOutlet UITableView *tableView;






//*******************
@property (strong, nonatomic) IBOutlet UIBarButtonItem *CancleItemButton;
- (IBAction)CancleAction:(id)sender;



@property (strong, nonatomic) IBOutlet UIBarButtonItem *DeleteItemButton;
- (IBAction)DeleteAction:(id)sender;


@property (strong, nonatomic) IBOutlet UIBarButtonItem *EditItemButton;

- (IBAction)EditAction:(id)sender;


//*******************



@end
