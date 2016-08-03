//
//  YSHYAudioManager.m
//  music
//
//  Created by 杨淑园 on 16/6/7.
//  Copyright © 2016年 yangshuyaun. All rights reserved.
//

#import "YSHYAudioManager.h"
static YSHYAudioManager *_instance = nil;
@implementation YSHYAudioManager

+(void)initialize
{
    //音频会话
    AVAudioSession * session = [AVAudioSession sharedInstance];
    //设置 会话类型  播放类型 播放模式(会自动停止其他音乐的播放)
    [session setCategory:AVAudioSessionCategoryPlayback  error:nil];
    //激活会话
    [session setActive:YES error:nil];
}
+(instancetype)YSHYAudioInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
    });
    return  _instance;
}

-(instancetype)init
{
    __block typeof(self) weakSelf = self;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if((weakSelf = [super init])) {
            
        }
    });
    return self;
}
+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return  _instance;
}


@end
