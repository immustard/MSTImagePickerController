//
//  MSTPhotoPreviewCell.m
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/19.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "MSTPhotoPreviewImageCell.h"

@implementation MSTPhotoPreviewImageCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, frame.size.width - 20, frame.size.height)];
        view.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:view];
    }
    return self;
}
@end
