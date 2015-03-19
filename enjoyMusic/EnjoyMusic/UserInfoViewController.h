//
//  UserInfoViewController.h
//  EnjoyMusic
//
//  Created by administrator on 14-10-30.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInfoViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableview;




@end
