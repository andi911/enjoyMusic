//
//  LoadImageView.m
//  EnjoyMusic
//
//  Created by Administrator on 14-10-13.
//  Copyright (c) 2014年 com.gemptc.team3. All rights reserved.
//

#import "LoadImageView.h"
#import "ASIHTTPRequest.h"
#import "EMAppDelegate.h"

@interface LoadImageView()<UIScrollViewDelegate>
{
    EMAppDelegate*  del;
    CGFloat width;
    CGFloat height;
    NSMutableArray *imageArray;
    NSString* p;
}
@property (strong,nonatomic) NSTimer * timer;
@property (assign) int page;
@end

@implementation LoadImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    imageArray = [NSMutableArray array];
    width = self.scrollView.frame.size.width;
    height = self.scrollView.frame.size.height;
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(width * 8, height);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.page = 0;
    self.pageControl.numberOfPages = 8;
    self.pageControl.pageIndicatorTintColor = [UIColor blackColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor greenColor];
    self.pageControl.enabled = NO;
    
    
    del = [UIApplication sharedApplication].delegate;
    
    
    
    [self sendSynchronousRequest];
    
    [self addTimer];

}

#pragma mark - 发送同步请求
-(void)sendSynchronousRequest
{
    NSURL *url = [NSURL URLWithString:@"http://tingapi.ting.baidu.com/v1/restserver/ting?method=baidu.ting.plaza.getFocusPic&format=json"];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setTimeOutSeconds:30];     //设置超时时间为10秒
    
    //启动同步请求
    [request startSynchronous];
    
    

    
    
    //请求成功
    if (request.error == nil) {
        //获得请求的结果
        NSData *data = [request responseData];
        
        //解析JSON
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

        NSArray *arr = [dic objectForKey:@"pic"];

        for (NSDictionary *obj in arr) {
            p = [obj objectForKey:@"randpic"];
            
                [self loadImage:p];   //开启异步线程加载图片
        }
        
    }
    
    
    
    
    //请求失败，调用本地图片
    else{
        NSArray* a = @[@"Image1.png",@"Image2.png",@"Image3.png",@"Image4.png",@"Image5.jpg",@"Image6.jpg",@"Image7.jpg",@"Image8.jpg"];
        for (NSString* ns in a) {
            UIImage* ima = [UIImage imageNamed:ns];
            [imageArray addObject:ima];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake((imageArray.count-1) * width, 0, width, height);
            [button setBackgroundImage:ima forState:UIControlStateNormal];
            [self.scrollView addSubview:button];

        }
        
        
    }
    
    
    
    
}






#pragma mark - 启动同步请求－请求图片
-(void)loadImage:(NSString *)URLPath
{
    NSURL *url = [NSURL URLWithString:URLPath];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    request.delegate = self;
    
    //启动异步请求
    [request startAsynchronous];
    
}

#pragma mark - ASIHTTPRequest异步请求委托方法
-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *data = [request responseData];
    UIImage *image = [UIImage imageWithData:data];
    
    [imageArray addObject:image];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake((imageArray.count-1) * width, 0, width, height);
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [self.scrollView addSubview:button];


}






#pragma mark - 请求失败
-(void)requestFailed:(ASIHTTPRequest *)request
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"首页图片加载失败，请检查网络！" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}



#pragma mark 滚动图片计时器
- (void)addTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}



- (void)nextImage
{
    // 1.增加pageControl的页码
    if (self.pageControl.currentPage == 7) {
        self.page = 0;
    } else {
        self.page = self.pageControl.currentPage + 1;
    }

    
    
    
    
    // 2.计算scrollView滚动的位置
    CGFloat offsetX = self.page * self.scrollView.frame.size.width;
    CGPoint offset = CGPointMake(offsetX, 0);
    [self.scrollView setContentOffset:offset animated:YES];
}

#pragma mark scrollView 代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 根据scrollView的滚动位置决定pageControl显示第几页
    CGFloat scrollW = scrollView.frame.size.width;
    int page = (scrollView.contentOffset.x + scrollW * 0.5) / scrollW;
    self.pageControl.currentPage = page;
}

/**
 *  开始拖拽的时候调用
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // 停止定时器(一旦定时器停止了,就不能再使用)
    [self removeTimer];
}
/**
 
 
 
 
 *  移除定时器
 */
- (void)removeTimer
{
    [self.timer invalidate];
    self.timer = nil;
}
/**
 
 
 
 
 
 *  停止拖拽的时候调用
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // 开启定时器
    [self addTimer];
}







@end











