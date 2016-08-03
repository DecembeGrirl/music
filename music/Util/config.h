//
//  config.h
//  music
//
//  Created by 杨淑园 on 16/6/7.
//  Copyright © 2016年 yangshuyaun. All rights reserved.
//

#ifndef config_h
#define config_h

#define CGM(_X,_Y,_W,_H)                                                                                                   CGRectMake(_X,_Y,_W,_H)

#define RGB_COLOR(_STR_) ([UIColor colorWithRed:[[NSString stringWithFormat:@"%lu", strtoul([[_STR_ substringWithRange:NSMakeRange(1, 2)] UTF8String], 0, 16)] intValue] / 255.0 green:[[NSString stringWithFormat:@"%lu", strtoul([[_STR_ substringWithRange:NSMakeRange(3, 2)] UTF8String], 0, 16)] intValue] / 255.0 blue:[[NSString stringWithFormat:@"%lu", strtoul([[_STR_ substringWithRange:NSMakeRange(5, 2)] UTF8String], 0, 16)] intValue] / 255.0 alpha:1.0])

#define KSCREENWIDTH [[UIScreen mainScreen]                                                                                bounds].size.width
#define KSCREENHEIGHT [[UIScreen mainScreen]                                                                                bounds].size.height

#endif /* config_h */
