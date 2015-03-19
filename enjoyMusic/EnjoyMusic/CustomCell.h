//
//  CustomCell.h
//  EnjoyMusic
//
//  Created by administrator on 14-9-23.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *SingerImage;

@property (strong, nonatomic) IBOutlet UILabel *SongName;
@property (strong, nonatomic) IBOutlet UILabel *SongDetail;

@property (strong, nonatomic) IBOutlet UILabel *ShowLrcStatement;





@end
