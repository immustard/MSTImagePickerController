//
//  UIView+MST.h
//  MSTTools_OC
//
//  Created by 张宇豪 on 2017/4/13.
//  Copyright © 2017年 张宇豪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface UIView (MST)

#pragma mark - Frame
@property (assign, nonatomic) CGFloat mst_left;

@property (assign, nonatomic) CGFloat mst_top;

@property (assign, nonatomic) CGFloat mst_right;

@property (assign, nonatomic) CGFloat mst_bottom;

@property (assign, nonatomic) CGFloat mst_width;

@property (assign, nonatomic) CGFloat mst_height;

@property (assign, nonatomic) CGFloat mst_centerX;

@property (assign, nonatomic) CGFloat mst_centerY;

@property (assign, nonatomic) CGPoint mst_origin;

@property (assign, nonatomic) CGSize mst_size;


#pragma mark - SubView
/**
 根据tag得到子视图
 */
- (__kindof UIView *)mst_subviewWithTag:(NSInteger)tag;

/**
 删除所有子视图
 */
- (void)mst_removeAllSubviews;

/**
 根据tag删除子视图
 */
- (void)mst_removeViewWithTag:(NSInteger)tag;

/**
 根据tag删除多个子视图
 */
- (void)mst_removeViewWithTags:(NSArray *)tagArray;

/**
 删除比该tag小的子视图
 */
- (void)mst_removeViewWithTagLessThan:(NSInteger)tag;

/**
 删除比该tag大的子视图
 */
- (void)mst_removeViewWithTagGreaterThan:(NSInteger)tag;


#pragma mark - View Controller
/**
 得到该视图所在的视图控制器
 */
- (__kindof UIViewController *)mst_responderViewController;

#pragma mark - Draw Rect
//设置圆角
- (void)mst_cornerRadius:(CGFloat)radius;

//设置圆角线框
- (void)mst_cornerRadius:(CGFloat)radius lineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor;

//设置某几个角为圆角
- (void)mst_corners:(UIRectCorner)corners cornerRadius:(CGFloat)radius;

//设置圆形
- (void)mst_circular;

/** 添加点击弹簧动画 */
- (void)addSpringAnimation;

@end
