//
//  ViewController.m
//  music
//
//  Created by 杨淑园 on 16/6/7.
//  Copyright © 2016年 yangshuyaun. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()<UITableViewDataSource, UITableViewDelegate,AVAudioPlayerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray * lrcArray; // 歌词
@property (nonatomic, strong) NSMutableArray * timeArray; // 时间
@property (nonatomic, strong) NSArray * songArray;

@property (nonatomic, strong) NSTimer * timer;  //定时器
@property (nonatomic, strong) UISlider * slider; //播放进度条
@property (nonatomic, strong) UISlider * volumeSlider;// 音量
@property (nonatomic, strong) UILabel * labelTime;
@property (nonatomic, strong) UILabel * labeltotalTime;
@property (nonatomic, assign) NSTimeInterval totalTime;  //总时长
@property (nonatomic, assign) NSTimeInterval per;//slider每一秒的value

@property (nonatomic, strong) AVAudioPlayer * player;

@property (nonatomic, strong) NSString * currentTime;

@property (nonatomic, strong) UIImageView * backImageView;
@property (nonatomic, strong) UIImageView * songImageView;

@property (nonatomic, strong) UIImageView * CDImageView;
@property (nonatomic, strong) NSIndexPath * currentIndexPath;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initsView];
    [self initsData];
    
    NSString * name =self.songArray[0][@"name"] ;
    [self getAudioInfo:name type:@"mp3"];
    [self parseLrcName:@"lrc" type:@"txt"];
    
    [self initTimer];
    
    [self.customNav setNavTitle:name];
    [self beginAni];
    
}
-(void)initsView
{
    self.backImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    [self.backImageView setImage:[UIImage imageNamed:@"cm2_play_disc_mask@3x"]];
    [self.view addSubview:self.backImageView];
    
    
    self.songImageView =[[UIImageView alloc]initWithFrame:CGM((KSCREENWIDTH - 200) / 2, 185, 200, 200)];
    [self.songImageView setBackgroundColor:[UIColor redColor]];
    self.songImageView.layer.masksToBounds = YES;
    self.songImageView.layer.cornerRadius = 100;
    [self.songImageView setImage:[UIImage imageNamed:@"不将就.jpg"]];
    [self.view addSubview:self.songImageView];
    
    
    self.CDImageView = [[UIImageView alloc]initWithFrame:CGM( 50, 148, KSCREENWIDTH - 100, KSCREENWIDTH - 100)];
    [self.CDImageView setImage:[UIImage imageNamed:@"cm2_play_disc"]];
    [self.view addSubview:self.CDImageView];
    
    
    self.tableView = [[UITableView alloc]initWithFrame:CGM(0, 64, KScreenWidth, KScreenHeight - 120)];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.hidden = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    self.volumeSlider = [[UISlider alloc]initWithFrame:CGM(KSCREENWIDTH - 120, KSCREENHEIGHT - 200,200 , 10)];
    self.volumeSlider.transform = CGAffineTransformMakeRotation(-M_PI / 2);
    [self.volumeSlider addTarget:self action:@selector(volumeSliderVauleChange) forControlEvents:UIControlEventTouchUpInside];
    self.volumeSlider.hidden = YES;
    [self.view addSubview:self.volumeSlider];
    
    [self initsToolView];
    
}
-(void)initsToolView
{
    UIView * view = [[UIView alloc]initWithFrame:CGM(0, KSCREENHEIGHT - 60 , KSCREENWIDTH, 60)];
    [self.view  addSubview:view];
    
    self.slider = [[UISlider alloc]initWithFrame:CGM(60, 5, KSCREENWIDTH - 120, 10)];
    [self.slider addTarget:self action:@selector(sliderVauleChange) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.slider];
    
    self.labelTime = [[UILabel alloc]initWithFrame:CGM(5, 5, 60, 10)];
    self.labelTime.text = @"00:00";
    self.labelTime.font = [UIFont systemFontOfSize:14.0];
    [view addSubview:self.labelTime];
    
    self.labeltotalTime =[[UILabel alloc]initWithFrame:CGM(KSCREENWIDTH - 55, 5, 60, 10)];
    self.labeltotalTime.text = @"00:00";
    self.labeltotalTime.font = [UIFont systemFontOfSize:14.0];
    [view addSubview:self.labeltotalTime];
    
    
    UIButton * last = [UIButton buttonWithType:UIButtonTypeCustom];
    [last setFrame:CGM(KSCREENWIDTH /2 - 75, 30, 25, 25)];
    [last setImage:[UIImage imageNamed:@"icon_last"] forState:UIControlStateNormal];
    [last addTarget:self action:@selector(HandleLast) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:last];
    
    UIButton * next = [UIButton buttonWithType:UIButtonTypeCustom];
    [next setFrame:CGM(KSCREENWIDTH /2 + 50, 30, 25, 25)];
    [next setImage:[UIImage imageNamed:@"icon_next"] forState:UIControlStateNormal];
    [next addTarget:self action:@selector(HandleNext) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:next];
    
    UIButton * start = [UIButton buttonWithType:UIButtonTypeCustom];
    [start setFrame:CGM((KSCREENWIDTH - 25)/2, 30, 25, 25)];
    [start setImage:[UIImage imageNamed:@"icon_pause"] forState:UIControlStateNormal];
    [start addTarget:self action:@selector(HandleStart:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:start];
}

-(void)initsData
{
    self.lrcArray  = [[NSMutableArray alloc]init];
    self.timeArray = [[NSMutableArray alloc]init];
    
    self.songArray = [[NSArray alloc]init];
    
    NSString * path =  [[NSBundle mainBundle] pathForResource:@"songList" ofType:@"plist"];
   self.songArray  = [NSArray arrayWithContentsOfFile:path];
}

-(void)initTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];
    [self.timer fire];
}

-(void)invalidateTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

-(void)handleTimer
{
    NSString * mmstr,* ssStr;
    //  改变进度条的值
    self.slider.value =  self.player.currentTime / self.totalTime;
    //pow(60,2)  60 的2次方 函数
    int mm = self.player.currentTime / 60;
    int ss = (int)self.player.currentTime %  60;
    
    mmstr = mm<10?[NSString stringWithFormat:@"0%d:",mm]:[NSString stringWithFormat:@"%d:",mm];
    ssStr = ss<10?[NSString stringWithFormat:@"0%d",ss]:[NSString stringWithFormat:@"%d",ss];
    
    self.currentTime =[mmstr stringByAppendingString:ssStr];
    
    self.labelTime.text = self.currentTime;
    
    for (int i = 0; i < self.lrcArray.count; i ++) {
        
        NSString * time = self.lrcArray[i][@"time"];
        
        if([self.currentTime isEqualToString:time])
        {
            self.currentIndexPath =[NSIndexPath indexPathForItem:i inSection:0];
            [self.tableView selectRowAtIndexPath:self.currentIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
}

//点击上一曲
-(void)HandleLast
{
    NSLog(@" --=-=-=-= ");
    
}
-(void)HandleNext
{
    NSLog(@" --=-=-=-= ");
}
-(void)HandleStart:(UIButton *)sender
{
    if([sender.imageView.image isEqual:[UIImage imageNamed:@"icon_pause"]])
    {
        [sender setImage:[UIImage imageNamed:@"icon_start"] forState:UIControlStateNormal];
        [self invalidateTimer];
        [self.player pause];
        [self pauseAniInLayer:self.songImageView.layer];
    }
    else
    {
        self.player.currentTime = self.slider.value * self.totalTime;
        [self initTimer];
        [sender setImage:[UIImage imageNamed:@"icon_pause"] forState:UIControlStateNormal];
        [self.player play];
        [self resumeAniInLayer:self.songImageView.layer];
    }
}

-(void)sliderVauleChange
{
    [self.timer setFireDate:[NSDate distantFuture]];
    self.player.currentTime = self.slider.value * self.totalTime;
    [self.player playAtTime:self.player.currentTime];
    [self.timer setFireDate:[NSDate distantPast]];
}

-(void)volumeSliderVauleChange
{
    self.player.volume = self.volumeSlider.value * 10;
    NSLog(@"%f   %f",self.slider.value,self.player.volume);

}

-(void)getAudioInfo:(NSString *)name type:(NSString *)type
{
    NSString * path = [[NSBundle mainBundle]pathForResource:name ofType:type];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSError * error = nil;
        // 初始化 player
        self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];  //使用 fileURLWithPath
        self.player.delegate = self;
        self.totalTime =  self.player.duration;
        self.player.numberOfLoops = CGFLOAT_MAX;
    
        int mm = self.totalTime / 60;
        int ss = (int)self.totalTime % 60;
        
        NSString * mmStr = mm< 10?[NSString stringWithFormat:@"0%d:",mm]: [NSString stringWithFormat:@"%d:",mm];
        NSString * ssStr =  ss<10?[NSString stringWithFormat:@"0%d",ss]: [NSString stringWithFormat:@"%d",ss];
        
        self.labeltotalTime.text = [mmStr stringByAppendingString:ssStr];
        
        self.player.volume = 3;
        self.volumeSlider.value = self.player.volume / 10;
        [self.player prepareToPlay];

        [self.player play];
        
    }
}
// 解析歌词
-(void)parseLrcName:(NSString *)fileName type:(NSString *)type
{
    //获取歌词的路径
    NSString * path = [[NSBundle mainBundle]pathForResource:fileName ofType:type];
    
    // 读取歌词
    NSString * lrc = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSArray * tempArr = [lrc componentsSeparatedByString:@"\\n"];
    //将歌词与时间分开
    for (int i = 0 ; i < tempArr.count ; i++) {
        NSString *str = tempArr[i];
        if([str isEqualToString:@""])
            continue;
        
        NSArray * arr = [str componentsSeparatedByString:@"]"];
        NSString * time;
        NSString * word = @"";
        for (int j = 0 ;j < arr.count - 1; j++) {
            NSString *tempStr = arr[j];
            if ([tempStr hasPrefix:@"["]) {
                time = [tempStr substringWithRange:NSMakeRange(1, 5)];
                if(![tempStr isEqualToString:arr.lastObject])
                    word = arr.lastObject;
            }
            NSDictionary * dic = @{@"time":time,@"word":word};
            [self.lrcArray addObject:dic];
        }
    }
    
    //对歌词进行排序
    [self sorttime];
}
//按照时间对歌词进行排序
-(void)sorttime
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];//其中，time为数组中的对象的属性，这个针对数组中存放对象比较更简洁方便
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
    [self.lrcArray sortUsingDescriptors:sortDescriptors];
}



#pragma make -----AVAudioDlegate---------
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    
    [self.timer invalidate];
    self.timer = nil;
    [self.player stop];
    
    self.slider.value = 0;
}

#pragma  make - tableViewDelegate ----

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.lrcArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"CellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
       
    }
    cell.backgroundColor = [UIColor clearColor];
    NSString * str = self.lrcArray[indexPath.row][@"word"];
     cell.textLabel.text =str;
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    
    cell.textLabel.textColor = [UIColor magentaColor];
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // 设置文字高亮颜色
    cell.textLabel.highlightedTextColor = [UIColor colorWithRed:0.2 green:0.3 blue:0.9 alpha:1];
    
    
    // 设置被选取的cell
    UIView *view = [[UIView alloc]initWithFrame:cell.contentView.frame];
    view.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = view;
    
        return  cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  30;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [tableView selectRowAtIndexPath:self.currentIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    [self tapAnyView];
}

#pragma mark ------- CD旋转效果 -----------
-(void)beginAni
{
    [UIView animateWithDuration:5.0 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        CABasicAnimation* aniRotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        aniRotate.fromValue =@0;
        aniRotate.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
        aniRotate.duration = 10.0;
        aniRotate.repeatCount =CGFLOAT_MAX;
        aniRotate.cumulative = YES;
        [self.songImageView.layer addAnimation:aniRotate forKey:@"songImageView_rotate"];
    } completion:^(BOOL finished) {
        
    }];
}

-(void)pauseAniInLayer:(CALayer *)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}


-(void)resumeAniInLayer:(CALayer *)layer
{
    CFTimeInterval  pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil]-pausedTime ;
    layer.beginTime = timeSincePause;
}


-(void)tapAnyView
{
    if(self.tableView.hidden == YES)
    {
        self.CDImageView.hidden = YES;
        self.songImageView.hidden = YES;
    }
    else
    {
        self.CDImageView.hidden = NO;
        self.songImageView.hidden = NO;
    }
    
    self.volumeSlider.hidden = !self.volumeSlider.hidden;
    self.tableView.hidden = !self.tableView.hidden;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self tapAnyView];
    
}
@end
