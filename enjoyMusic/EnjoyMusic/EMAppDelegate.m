//
//  EMAppDelegate.m
//  EnjoyMusic
//
//  Created by Administrator on 14-9-12.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import "EMAppDelegate.h"

@implementation EMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *home  = NSHomeDirectory();
    NSLog(@"%@",home);
    self.filePath = [[NSString alloc] initWithFormat:@"%@/Documents",home];
    NSLog(@"%@",self.filePath);
    

    self.OnLineSongArray = [[NSMutableArray alloc]init];
    self.LocalSongArray  = [[NSMutableArray alloc]init];
    self.MyKSongArray    = [[NSMutableArray alloc]init];
    self.iPodSongArray   = [[NSMutableArray alloc]init];
    
    self.DownloadFailedAccount   = [[NSMutableArray alloc]init];
    self.DownloadSuccessAccount  = [[NSMutableArray alloc]init];
    self.UrlAndNameForLoadSongs  = [[NSMutableArray alloc]init];

    NSFileManager* manager = [NSFileManager defaultManager];
    
    NSString* filePath1 = [NSString stringWithFormat:@"%@/CodeDirectory.plist",self.filePath];
    if ([manager fileExistsAtPath:filePath1] == NO) {
        [manager createFileAtPath:filePath1 contents:nil attributes:nil];
    }
    self.UserFilePath = filePath1;
    
    
    
    NSString* filePath2 = [NSString stringWithFormat:@"%@/SonglrcFilePath",self.filePath];
    if ([manager fileExistsAtPath:filePath2] == NO) {
        [manager createDirectoryAtPath:filePath2 withIntermediateDirectories:YES attributes:nil error:nil];
    }
    self.SonglrcFilePath = filePath2;
    
    
    NSString* filePath3 = [NSString stringWithFormat:@"%@/LocalSongFilePath",self.filePath];
    if ([manager fileExistsAtPath:filePath3] == NO) {
        [manager createDirectoryAtPath:filePath3 withIntermediateDirectories:YES attributes:nil error:nil];
        
    }
    self.LocalSongFilePath = filePath3;
    
    
    
    NSString* filePath4 = [NSString stringWithFormat:@"%@/UserKMusicFilePath",self.filePath];
    if ([manager fileExistsAtPath:filePath4] == NO) {
        [manager createDirectoryAtPath:filePath4 withIntermediateDirectories:YES attributes:nil error:nil];
        
    }
    self.UserKMusicFilePath = filePath4;
    
    
    NSString* filePath5 = [NSString stringWithFormat:@"%@/KMusicSourceFilePath",self.filePath];
    if ([manager fileExistsAtPath:filePath5] == NO) {
        [manager createDirectoryAtPath:filePath5 withIntermediateDirectories:YES attributes:nil error:nil];
        
    }
    self.KMusicSourceFilePath = filePath5;
    
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
