//
//  TimeClosureViewController.m
//  EnjoyMusic
//
//  Created by administrator on 14-10-30.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import "TimeClosureViewController.h"
#import "EMAppDelegate.h"

@interface TimeClosureViewController ()
<UIPickerViewDataSource,UIPickerViewDelegate,UIAlertViewDelegate>
{
    NSMutableArray* array1;
    NSMutableArray* array2;
    NSMutableArray* array3;

    int hour ;
    int min  ;
    NSTimer* Time;
    EMAppDelegate* del;
    
}


@end

@implementation TimeClosureViewController

static int totalTime = 0 ;




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    del = [UIApplication sharedApplication].delegate;
    self.TimeClosurePickerView.dataSource=self;
    self.TimeClosurePickerView.delegate=self;
    self.TimeClosurePickerView.showsSelectionIndicator = YES;
    
    array1 = [[NSMutableArray alloc]init];
    array2 = [[NSMutableArray alloc]init];
    array3 = [[NSMutableArray alloc]init];
    
    
    UIImage* image = [UIImage imageNamed:@"定时页面背景.jpg"];
    UIImageView* view = [[UIImageView alloc]initWithFrame:self.view.bounds];
    view.autoresizingMask = UIViewContentModeScaleAspectFill;
    view.image = image;
    view.alpha = 0.3;
    [self.view insertSubview:view atIndex:0];
    
    
    
    for (int i = 0; i < 12; i ++) {

        NSString* n = [NSString stringWithFormat:@"%i",i];
        [array1 addObject:n];
    }
    
    
    
    for (int j = 1; j < 60; j ++) {
        NSString* s = [NSString stringWithFormat:@"%i",j];
        [array2 addObject:s];
    }
    
    [array3 addObject:array1];
    [array3 addObject:array2];
    
    
    [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(Showtime) userInfo:Nil repeats:YES];
    
}

-(void)Showtime{
    
    NSInteger i = [self.TimeClosurePickerView selectedRowInComponent:0];
    self.IntengerForHourLael.text = [NSString stringWithFormat:@"%i",i];

    NSInteger j = [self.TimeClosurePickerView selectedRowInComponent:1];
    self.IntengerForMinLabel.text = [NSString stringWithFormat:@"%i",j + 1];
    

}







#pragma mark - pickerview的代理方法

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{

    return 2;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{

    return [array3[component] count];

}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{

    return 120;

}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{

    return 60;

}


//显示出来的每行的文本
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{

    if (component == 0) {
        return array1[row];
    }
    if (component == 1) {
        return array2[row];
    }
    return 0;
}









- (IBAction)StartTiming:(id)sender {
    
     hour = [self.IntengerForHourLael.text intValue];
     min  = [self.IntengerForMinLabel.text intValue];
    
    NSString* message = [NSString stringWithFormat:@"播放器将在%i小时%i分钟后自动关闭",hour,min];
    UIAlertView* view = [[UIAlertView alloc]initWithTitle:Nil message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [view show];
    
}


#pragma mark - UIAlertView代理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    self.view.alpha = 0.1;
    if (buttonIndex == 0) {
        [self.navigationController popViewControllerAnimated:YES];

    }

    if (buttonIndex == 1) {
        totalTime = hour * 60 * 60 + min * 60;
        Time = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(AutomaticTiming) userInfo:Nil repeats:YES];
        [self.navigationController popViewControllerAnimated:YES];

    }
}






-(void)AutomaticTiming{

    totalTime -= 1;
    if (totalTime == 0) {
     [  Time invalidate];
        [del.PLAYER stop];
        [del.player stop];
        [del.playerForiPod stop];
        [del.playerForKM stop];
    }

}






- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end





