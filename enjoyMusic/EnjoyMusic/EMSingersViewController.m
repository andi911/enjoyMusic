

#import "EMSingersViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "Singer.h"
#import "EMSingerSongViewController.h"
#import "AIMTableViewIndexBar.h"


@interface EMSingersViewController ()<AIMTableViewIndexBarDelegate>
{
    NSURL* url;
    NSMutableArray *array;
    int count;
    NSArray *typeList;
    NSArray *letter;
    NSArray *sections;
    NSMutableArray *rows;
    NSMutableArray* row;
    
    __weak IBOutlet AIMTableViewIndexBar    *indexBar;
    
}
@end

@implementation EMSingersViewController
static int flag = 1;

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
    count = 0;
    [super viewDidLoad];
    
    self.SingerListTableview.delegate   = self;
    self.SingerListTableview.dataSource = self;
    
    
    
    //设置标题
    typeList = @[@"华语男歌手",@"华语女歌手",@"华语组合",@"欧美组合"];
    for (int i = 0; i<typeList.count; i++) {
        [self.singerTypeSegmentButton setTitle:[typeList objectAtIndex:i] forSegmentAtIndex:i];
    }
    
    [self disPlaySingers];
    
    //因为歌手的firsrchar属性有空的（16个），设置1挑出以便剔除
    letter = @[@"1",@"A", @"B", @"C", @"D", @"E", @"F", @"G",@"H", @"H", @"J", @"K", @"L", @"M", @"N",@"O", @"P", @"Q", @"R", @" S", @"T", @"U",@"V", @"W", @"X", @"Y", @"Z"];
    
    //把UItableview的section属性设置为26，每个section的标题依次为A，B,C............Z
    sections = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G",@"H", @"H", @"J", @"K", @"L", @"M", @"N",@"O", @"P", @"Q", @"R", @" S", @"T", @"U",@"V", @"W", @"X", @"Y", @"Z"];
    indexBar.delegate = self;
    
}



#pragma mark - 歌手类型切换
- (IBAction)changeSingerType:(id)sender {
    
    flag = self.singerTypeSegmentButton.selectedSegmentIndex + 1;
    [self disPlaySingers];
    
}


-(void)disPlaySingers{
    array = [NSMutableArray array];     //初始化，顺便清空之前存储的数据
    //    indexBar = [[AIMTableViewIndexBar alloc]init];
    NSString* str;
    
    if (flag == 1) {
        str = @"http://10.110.2.151:8888/ChinaManArtistList.php";
    }
    
    if (flag == 2) {
        str = @"http://10.110.2.151:8888/ChinaWomanArtistList.php";
    }
    
    if (flag == 3) {
        str = @"http://10.110.2.151:8888/ChinaGroupArtistList.php";
    }
    
    if (flag == 4) {
        str = @"http://10.110.2.151:8888/OccidentGroupArtistList.php";
    }
    
    url = [[NSURL alloc]initWithString:str];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    request.delegate = self;
    [request startAsynchronous];
    [request setTimeOutSeconds:60];
    
}


#pragma mark - ASIHTTPRequest异步请求委托方法
-(void)requestFinished:(ASIHTTPRequest *)request
{
    //获得请求的结果
    NSData *data = [request responseData];
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSArray *arr = [dic objectForKey:@"result"];
    for (NSDictionary *obj in arr) {
        Singer *n = [[Singer alloc]init];
        n.ting_uid = [obj objectForKey:@"ting_uid"];
        n.name = [obj objectForKey:@"name"];
        n.firstchar = [obj objectForKey:@"firstchar"];
        if (n.firstchar.length == 0) {
            n.firstchar = @"1";
        }
        [array addObject:n];
        
    }
    
    
    [array removeObjectAtIndex:0];
    
    rows = [[NSMutableArray alloc]init];
    
    
    for (NSString* mm in sections) {
        //*****************************************************************
        //位置很关键，否则会产生错误  ---- 要添加多个对象，每个对象需要创建
        
        row  = [[NSMutableArray alloc]init];
        
        //*****************************************************************
        
        for (Singer* obj in array) {
            if ([obj.firstchar isEqualToString:mm]) {
                
                //firstchar和name是两个不同的属性，将它们先连缀在一起
                NSString* p = [NSString stringWithFormat:@"%@%@",obj.firstchar,obj.name];
                [row addObject:p];
                
            }
        }
        [rows addObject:row];
        
    }
    
    
    [self.SingerListTableview reloadData];
    
}

#pragma mark - 请求失败
-(void)requestFailed:(ASIHTTPRequest *)request
{
    UIAlertView* vie = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请求失败，请检查网络或服务器" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [vie show];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [indexBar setIndexes:sections]; // to always have exact number of sections in table and indexBar
    return [sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [rows[section] count];
    
}


- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return sections[section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    
    NSString* ns = rows[indexPath.section][indexPath.row];
    NSUInteger le = ns.length - 1;
    NSRange range = {1,le};
    NSString* nsst = [ns substringWithRange:range];
    [cell.textLabel setText:nsst];
    return cell;
    
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Singer* singers = [[Singer alloc]init];
    NSString* ns = rows[indexPath.section][indexPath.row];
    NSUInteger le = ns.length - 1;
    NSRange range = {1,le};
    NSString* nsst = [ns substringWithRange:range];
    for (Singer* si in array) {
        if ([si.name isEqualToString:nsst]) {
            singers.ting_uid = si.ting_uid;
        }
    }
    
    
    //在storyboard里面通过标识符SongForSingerVC找到相对应得视图控制器
    EMSingerSongViewController *vc =  [self.storyboard instantiateViewControllerWithIdentifier:@"SongForSingerVC"];
    vc.ting_uid = singers.ting_uid;
    [self.navigationController pushViewController:vc animated:YES];
    
}



#pragma mark - AIMTableViewIndexBarDelegate

- (void)tableViewIndexBar:(AIMTableViewIndexBar *)indexBar didSelectSectionAtIndex:(NSInteger)index{
    if ([self.SingerListTableview numberOfSections] > index && index > -1){   // for safety, should always be YES
        [self.SingerListTableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]
                                        atScrollPosition:UITableViewScrollPositionTop
                                                animated:YES];
    }
}



- (IBAction)Back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end














