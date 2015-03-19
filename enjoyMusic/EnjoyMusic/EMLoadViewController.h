//
//  EMLoadViewController.h
//  EnjoyMusic
//
//  Created by administrator on 14-9-25.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMprogressCell.h"

@interface EMLoadViewController : UIViewController
<progressCellDelegate,UITableViewDataSource,UITableViewDelegate>



@property (strong, nonatomic) IBOutlet UITableView *Loadlist;







@end
