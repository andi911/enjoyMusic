//
//  CustomCellForClearCache.m
//  EnjoyMusic
//
//  Created by administrator on 14-11-4.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import "CustomCellForClearCache.h"
#import "EMAppDelegate.h"

@implementation CustomCellForClearCache
{
    EMAppDelegate* del;

}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}



-(void)awakeFromNib{

    
    del = [UIApplication sharedApplication].delegate;

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)ClearCacheButton:(id)sender {
    
    NSInteger markNumber = self.tag - 100;
    NSFileManager* manager = [NSFileManager defaultManager];
    if (markNumber == 0) {
        NSArray *arr = [manager contentsOfDirectoryAtPath:del.LocalSongFilePath error:nil];
        for (NSString* p in arr) {
            NSString* path = [NSString stringWithFormat:@"%@/%@",del.LocalSongFilePath,p];
            [manager removeItemAtPath:path error:nil];
        }
    }
    if (markNumber == 1) {
        NSArray *arr = [manager contentsOfDirectoryAtPath:del.KMusicSourceFilePath error:nil];
        for (NSString* p in arr) {
            NSString* path = [NSString stringWithFormat:@"%@/%@",del.KMusicSourceFilePath,p];
            [manager removeItemAtPath:path error:nil];
        }
    }

    if (markNumber == 2) {
        NSArray *arr = [manager contentsOfDirectoryAtPath:del.UserFilePath error:nil];
        for (NSString* p in arr) {
            NSString* path = [NSString stringWithFormat:@"%@/%@",del.UserFilePath,p];
            [manager removeItemAtPath:path error:nil];
        }
    }

    
    if (markNumber == 3) {
        NSArray *arr = [manager contentsOfDirectoryAtPath:del.SonglrcFilePath error:nil];
        for (NSString* p in arr) {
            NSString* path = [NSString stringWithFormat:@"%@/%@",del.SonglrcFilePath,p];
            [manager removeItemAtPath:path error:nil];
        }
    }

    if (markNumber == 4) {
        NSArray *arr = [manager contentsOfDirectoryAtPath:del.UserFilePath error:nil];
        for (NSString* p in arr) {
            NSString* path = [NSString stringWithFormat:@"%@/%@",del.UserFilePath,p];
            [manager removeItemAtPath:path error:nil];
        }
    }
    
    
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"RefreshData" object:nil];
    
}






@end










