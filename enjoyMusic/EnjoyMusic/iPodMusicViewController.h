//
//  iPodMusicViewController.h
//  EnjoyMusic
//
//  Created by administrator on 14-10-16.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iPodMusicViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;






@end
