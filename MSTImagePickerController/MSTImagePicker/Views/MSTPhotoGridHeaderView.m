//
//  MSTPhotoGridHeaderView.m
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/18.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "MSTPhotoGridHeaderView.h"

@implementation MSTPhotoGridHeaderView

- (UILabel *)textLabel {
    if (!_textLabel) {
        self.textLabel = [UILabel new];
        _textLabel.textAlignment = NSTextAlignmentLeft;
        _textLabel.font = [UIFont systemFontOfSize:15];
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_textLabel];
        
        NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:_textLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:10];
        NSLayoutConstraint *vertical = [NSLayoutConstraint constraintWithItem:_textLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        
        [self addConstraints:@[leading, vertical]];
    }
    return _textLabel;
}
@end
