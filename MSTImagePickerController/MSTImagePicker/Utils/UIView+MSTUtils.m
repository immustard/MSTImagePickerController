//
//  UIView+Utils.m
//  RRChat
//
//  Created by Mustard on 16/8/12.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "UIView+MSTUtils.h"

@implementation UIView (MSTUtilsLayout)

- (CGFloat)top{
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)top{
    CGRect frame = self.frame;
    [self setFrame:CGRectMake(frame.origin.x, top, frame.size.width, frame.size.height)];
}

- (CGFloat)left{
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)left{
    CGRect frame = self.frame;
    [self setFrame:CGRectMake(left, frame.origin.y, frame.size.width, frame.size.height)];
}

- (CGFloat)bottom{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setBottom:(CGFloat)bottom{
    CGRect frame = self.frame;
    [self setFrame:CGRectMake(frame.origin.x, bottom - frame.size.height, frame.size.width, frame.size.height)];
}

- (CGFloat)right{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right{
    CGRect frame = self.frame;
    [self setFrame:CGRectMake(right - frame.size.width, frame.origin.y, frame.size.width, frame.size.height)];
}

- (CGFloat)width{
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width{
    CGRect frame = self.frame;
    [self setFrame:CGRectMake(frame.origin.x, frame.origin.y, width, frame.size.height)];
}

- (CGFloat)height{
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height{
    CGRect frame = self.frame;
    [self setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, height)];
}

- (CGSize)size{
    return CGSizeMake(self.frame.size.width, self.frame.size.height);
}

- (void)setSize:(CGSize)size{
    CGRect frame = self.frame;
    [self setFrame:CGRectMake(frame.origin.x, frame.origin.y, size.width, size.height)];
}

- (CGFloat)centerX{
    return self.frame.origin.x + self.frame.size.width/2.0;
}

- (void)setCenterX:(CGFloat)centerX{
    CGRect frame = self.frame;
    [self setFrame:CGRectMake(centerX - frame.size.width/2.0, frame.origin.y, frame.size.width, frame.size.height)];
}

- (CGFloat)centerY{
    return self.frame.origin.y + self.frame.size.height/2.0;
}

- (void)setCenterY:(CGFloat)centerY{
    CGRect frame = self.frame;
    [self setFrame:CGRectMake(frame.origin.x, centerY - frame.size.height/2.0, frame.size.width, frame.size.height)];
}

- (CGPoint)center{
    return CGPointMake(self.frame.origin.x + self.frame.size.width/2.0, self.frame.origin.y + self.frame.size.height/2.0);
}

- (void)setCenter:(CGPoint)center{
    CGRect frame = self.frame;
    [self setFrame:CGRectMake(center.x - frame.size.width/2.0, center.y - frame.size.height/2.0, frame.size.width, frame.size.height)];
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
    [self setFrame:CGRectMake(origin.x, origin.y, self.frame.size.width, self.frame.size.height)];
}

@end

@implementation UIView (MSTUtils)
#pragma mark ----- removeSubviews
- (void)MSTRemoveAllSubviews{
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
}

- (void)MSTRemoveViewWithTag:(NSInteger)tag {
    if (!tag) {
        return;
    }
    UIView *subview = [self viewWithTag:tag];
    [subview removeFromSuperview];
}

- (void)MSTRemoveViewWithTags:(NSArray *)tagArray {
    for (NSNumber *num in tagArray) {
        [self MSTRemoveViewWithTag:[num integerValue]];
    }
}

- (void)MSTRemoveViewWithTagLessThan:(NSInteger)tag{
    for (UIView *subview in self.subviews) {
        if (subview.tag > 0 && subview.tag < tag) {
            [subview removeFromSuperview];
        }
    }
}

- (void)MSTRemoveViewWithTagGreaterThan:(NSInteger)tag {
    for (UIView *subview in self.subviews) {
        if (subview.tag > 0 && subview.tag > tag) {
            [subview removeFromSuperview];
        }
    }
}

- (void)addSpringAnimation {
    CASpringAnimation *springAnimation = [CASpringAnimation animationWithKeyPath:@"transform.scale"];
    springAnimation.fromValue = @1;
    springAnimation.toValue = @1.01;
    
    springAnimation.mass = 1;
    springAnimation.damping = 7;
    springAnimation.stiffness = 50;
    springAnimation.duration = springAnimation.settlingDuration;
    springAnimation.initialVelocity = 200;
    
    [self.layer addAnimation:springAnimation forKey:nil];
}

#pragma mark ----- addGestures
- (void)MSTAddTapGestureWithTarget:(id)target action:(SEL)selector{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
    [self addGestureRecognizer:tap];
}

#pragma mark ----- addCornor
- (void)MSTAddCornorRadius:(CGFloat)radius{
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
}
@end
