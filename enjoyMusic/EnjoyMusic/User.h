//
//  User.h
//  EnjoyMusic
//
//  Created by administrator on 14-10-30.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject


@property int userId;                //用户ID
@property (copy, nonatomic) NSString *userName;        //用户姓名
@property (copy, nonatomic) NSString *userPassword;    //用户密码
@property (copy, nonatomic) NSString *userSex;         //用户性别
@property (copy, nonatomic) NSString *userTelphone;    //用户手机号
@property (copy, nonatomic) NSString *userEmail;       //用户邮箱
@property (copy, nonatomic) NSString *userHeadLink;        //用户头像


@end
