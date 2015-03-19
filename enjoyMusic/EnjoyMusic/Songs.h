//
//  Songs.h
//  EnjoyMusic
//
//  Created by administrator on 14-9-24.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Songs : NSObject
@property (strong,nonatomic)  NSString* SingerImageurl;
@property (strong,nonatomic)  NSString* SingerBigImageurl;
@property (strong, nonatomic) NSString* SongName;
@property (strong, nonatomic) NSString* SongLink;

@property (strong, nonatomic) NSString* SongDetail;
@property int song_id;



@property (strong,nonatomic)NSString *author;
@property(strong,nonatomic)NSString *smallpic;
@property(strong,nonatomic)NSString *songAccompanyLink;
@property(strong,nonatomic)NSString *lrcLink;










@end
