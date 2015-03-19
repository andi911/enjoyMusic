//
//  TheMoreViewController.h
//  EnjoyMusic
//
//  Created by Administrator on 14-10-13.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TheMoreViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
