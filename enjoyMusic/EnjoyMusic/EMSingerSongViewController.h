//
//  EMSingerSongViewController.h
//  EnjoyMusic
//
//  Created by administrator on 14-10-9.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMSingerSongViewController : UIViewController
<UITableViewDelegate,UITableViewDataSource>



//@property(nonatomic,strong)NSMutableArray* NewSongArray; //存储Songs对象
@property(copy, nonatomic) NSString *ting_uid;



@property (strong, nonatomic) IBOutlet UITableView *SongLIstTableview;


@property(strong,nonatomic) NSMutableArray* loadSongUrlAndName;  //传递要下载的歌曲的地址










//********************************
@property (strong, nonatomic) IBOutlet UIBarButtonItem *LoadButton;
- (IBAction)Loading:(id)sender;



@property (strong, nonatomic) IBOutlet UIBarButtonItem *StartLoadButton;

- (IBAction)StartLoading:(id)sender;




@property (strong, nonatomic) IBOutlet UIBarButtonItem *CancleButton;

- (IBAction)Cancling:(id)sender;


//********************************
















@end
