//
//  CustomCellForClearCache.h
//  EnjoyMusic
//
//  Created by administrator on 14-11-4.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CleartheCacheViewController.h"

@interface CustomCellForClearCache : UITableViewCell


@property (strong, nonatomic) IBOutlet UILabel *ItemNameLabel;


@property (strong, nonatomic) IBOutlet UILabel *ItemSizeLabel;




@property (strong, nonatomic) IBOutlet UIButton *ClearCacheButton;

- (IBAction)ClearCacheButton:(id)sender;


@property (strong, nonatomic) IBOutlet UIImageView *FolderImageView;

@property (strong, nonatomic) IBOutlet UILabel *UnitLabel;



@end
