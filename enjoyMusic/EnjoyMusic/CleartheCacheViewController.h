//
//  CleartheCacheViewController.h
//  EnjoyMusic
//
//  Created by administrator on 14-11-4.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CleartheCacheViewController : UIViewController







@property (strong, nonatomic) IBOutlet UILabel *FileSizeLabel;



@property (strong, nonatomic) IBOutlet UITableView *tableview;




- (IBAction)ClearAllFileOnce:(id)sender;





@end


