//
//  UIView+MST.m
//  MSTTools_OC
//
//  Created by 张宇豪 on 2017/4/13.
//  Copyright © 2017年 张宇豪. All rights reserved.
//

#import "UIView+MSTUtils.h"

@implementation UIView (MST)
#pragma mark - Frame
- (CGFloat)mst_left {
    return self.frame.origin.x;
}

- (void)setMst_left:(CGFloat)mst_left {
    CGRect frame = self.frame;
    frame.origin.x = mst_left;
    self.frame = frame;
}


- (CGFloat)mst_top {
    return self.frame.origin.y;
}

- (void)setMst_top:(CGFloat)mst_top {
    CGRect frame = self.frame;
    frame.origin.y = mst_top;
    self.frame = frame;
}


- (CGFloat)mst_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setMst_right:(CGFloat)mst_right {
    CGRect frame = self.frame;
    frame.origin.x = mst_right - frame.size.width;
    self.frame = frame;
}


- (CGFloat)mst_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setMst_bottom:(CGFloat)mst_bottom {
    CGRect frame = self.frame;
    frame.origin.y = mst_bottom - frame.size.height;
    self.frame = frame;
}


- (CGFloat)mst_centerX {
    return self.center.x;
}

- (void)setMst_centerX:(CGFloat)mst_centerX {
    self.center = CGPointMake(mst_centerX, self.center.y);
}


- (CGFloat)mst_centerY {
    return self.center.y;
}

- (void)setMst_centerY:(CGFloat)mst_centerY {
    self.center = CGPointMake(self.center.x, mst_centerY);
}


- (CGFloat)mst_width {
    return self.frame.size.width;
}

- (void)setMst_width:(CGFloat)mst_width {
    CGRect frame = self.frame;
    frame.size.width = mst_width;
    self.frame = frame;
}


- (CGFloat)mst_height {
    return self.frame.size.height;
}

- (void)setMst_height:(CGFloat)mst_height {
    CGRect frame = self.frame;
    frame.size.height = mst_height;
    self.frame = frame;
}


- (CGPoint)mst_origin {
    return self.frame.origin;
}

- (void)setMst_origin:(CGPoint)mst_origin {
    CGRect frame = self.frame;
    frame.origin = mst_origin;
    self.frame = frame;
}


- (CGSize)mst_size {
    return self.frame.size;
}

- (void)setMst_size:(CGSize)mst_size {
    CGRect frame = self.frame;
    frame.size = mst_size;
    self.frame = frame;
}



#pragma mark - SubView
- (UIView *)mst_subviewWithTag:(NSInteger)tag {
    for (UIView *sub in self.subviews) {
        if (sub.tag == tag)
            return sub;
    }
    return nil;
}

- (void)mst_removeAllSubviews {
    while ([self.subviews count] > 0) {
        UIView *subview = [self.subviews objectAtIndex:0];
        [subview removeFromSuperview];
    }
}

- (void)mst_removeViewWithTag:(NSInteger)tag {
    if (tag == 0)
        return;
    
    UIView *view = [self viewWithTag:tag];
    if (view)
        [view removeFromSuperview];
}

- (void)mst_removeSubViewArray:(NSMutableArray *)views {
    for (UIView *sub in views) {
        [sub removeFromSuperview];
    }
}
- (void)mst_removeViewWithTags:(NSArray *)tagArray {
    for (NSNumber *num in tagArray) {
        [self mst_removeViewWithTag:[num integerValue]];
    }
}
- (void)mst_removeViewWithTagLessThan:(NSInteger)tag {
    NSMutableArray *views = [NSMutableArray array];
    for (UIView *view in self.subviews) {
        if (view.tag > 0 && view.tag < tag)
            [views addObject:view];
    }
    [self mst_removeSubViewArray:views];
}
- (void)mst_removeViewWithTagGreaterThan:(NSInteger)tag {
    NSMutableArray *views = [NSMutableArray array];
    for (UIView *view in self.subviews) {
        if (view.tag > 0 && view.tag > tag)
            [views addObject:view];
    }
    [self mst_removeSubViewArray:views];
}

#pragma mark - View Controller
- (UIViewController *)mst_responderViewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]])
            return (UIViewController*)nextResponder;
    }
    return nil;
}

#pragma mark - Draw Rect
- (void)mst_circular {
    [self mst_cornerRadius:self.mst_width/2.0];
}

- (void)mst_cornerRadius:(CGFloat)radius {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = radius;
}

- (void)mst_corners:(UIRectCorner)corners cornerRadius:(CGFloat)radius {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius,radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

- (void)mst_cornerRadius:(CGFloat)radius lineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor {
    [self mst_cornerRadius:radius];
    self.layer.borderWidth = lineWidth;
    self.layer.borderColor = lineColor.CGColor;
}

- (void)addSpringAnimation {
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue < 9.0)
        return;

    CASpringAnimation *springAnimation = [CASpringAnimation animationWithKeyPath:@"transform.scale"];
    springAnimation.fromValue = @1;
    springAnimation.toValue = @1.01;
    
    springAnimation.mass = 1;
    springAnimation.damping = 7;
    springAnimation.stiffness = 50;
    springAnimation.duration = 0.2f;
    springAnimation.initialVelocity = 200.f;
    
    [self.layer addAnimation:springAnimation forKey:nil];
}

@end
