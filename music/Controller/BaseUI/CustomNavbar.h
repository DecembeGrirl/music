//
//  CustomNavbar.h
//  WumartLehui
//
//  Created by 杨淑园 on 15/8/12.
//  Copyright (c) 2015年 yangshuyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

#define KNAVBARHEIGHT  64.0
#define KScreenWidth [UIScreen mainScreen].bounds.size.width
#define KScreenHeight [UIScreen mainScreen].bounds.size.height
@interface CustomNavbar : UIView
@property (nonatomic, strong)UILabel *titleLabel;
@property (nonatomic, strong)UIButton *leftBtn;
@property (nonatomic, strong)UIButton *rightBtn;
@property (nonatomic, strong)UIViewController * VC;
@property (nonatomic, strong)UIButton *backBtn;

+ (CGFloat)barWidth;
+ (CGFloat)barHeight;

- (void)setBackBtn;
- (void)setLeftNavButton:(UIButton *)butt;
- (void)setRightNavButton:(UIButton *)butt;
- (void)setNavTitle:(NSString *)strTitle;
+ (UIButton *)createNavButtonByImageNormal:(NSString *)strNormal imageSelected:(NSString *)strSelected target:(id)target action:(SEL)action;
+ (UIButton *)createNavButttonByTitle:(NSString *)strTitle target:(id)target action:(SEL)action;
@end
