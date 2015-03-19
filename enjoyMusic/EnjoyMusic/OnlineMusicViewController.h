//
//  OnlineMusicViewController.h
//  EnjoyMusic
//
//  Created by Administrator on 14-9-16.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface OnlineMusicViewController : UIViewController
<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>



@property(strong,nonatomic) NSMutableArray* loadSongUrlAndName;  //传递要下载的歌曲的地址


@property (strong, nonatomic) IBOutlet UISearchBar *SearchBar;



@property (strong, nonatomic) IBOutlet UITableView *SongtableView;


//@property(nonatomic,strong)NSMutableArray* NewSongArray; //存储Songs对象

@property (strong, nonatomic) IBOutlet UIButton *Newsong;
- (IBAction)ForNewSong:(id)sender;


@property (strong, nonatomic) IBOutlet UIButton *PopularSong;
- (IBAction)ForPopularSong:(id)sender;


@property (strong, nonatomic) IBOutlet UIButton *searchSong;

- (IBAction)searchSong:(id)sender;


@property (strong, nonatomic) IBOutlet UIButton *Singers;




@property (strong, nonatomic) IBOutlet UIView *ViewForButtons;






//********************************
@property (strong, nonatomic) IBOutlet UIBarButtonItem *LoadButton;
- (IBAction)Loading:(id)sender;



@property (strong, nonatomic) IBOutlet UIBarButtonItem *StartLoadButton;

- (IBAction)StartLoading:(id)sender;




@property (strong, nonatomic) IBOutlet UIBarButtonItem *CancleButton;

- (IBAction)Cancling:(id)sender;


//********************************











@end







