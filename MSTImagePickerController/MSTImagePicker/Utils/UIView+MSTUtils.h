//
//  UIView+Utils.h
//  RRChat
//
//  Created by Mustard on 16/8/12.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MSTUtils)

@property (assign, nonatomic) CGFloat top;
@property (assign, nonatomic) CGFloat left;
@property (assign, nonatomic) CGFloat bottom;
@property (assign, nonatomic) CGFloat right;

@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;
@property (assign, nonatomic) CGSize  size;

@property (assign, nonatomic) CGFloat centerX;
@property (assign, nonatomic) CGFloat centerY;
@property (assign, nonatomic) CGPoint center;
@property (assign, nonatomic) CGPoint origin;

/** 移除所以子视图 */
-(void)MSTRemoveAllSubviews;
/** 根据tag移除子视图 */
-(void)MSTRemoveViewWithTag:(NSInteger)tag;
/** 根据tag移除多个子视图 */
-(void)MSTRemoveViewWithTags:(NSArray *)tagArray;
/** 移除小于该tag值的子视图，不包括0 */
-(void)MSTRemoveViewWithTagLessThan:(NSInteger)tag;
/** 移除大于该tag值的子视图 */
-(void)MSTRemoveViewWithTagGreaterThan:(NSInteger)tag;

/** 添加点击事件 */
- (void)MSTAddTapGestureWithTarget:(id)target action:(SEL)selector;

/** 添加圆角 */
- (void)MSTAddCornorRadius:(CGFloat)radius;
@end
