//
//  DisplayViewLayout.m
//  MSTImagePickerController
//
//  Created by Mustard on 2016/11/10.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "DisplayViewLayout.h"

@implementation DisplayViewLayout
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        
        self.minimumInteritemSpacing = 0;
        self.itemSize = CGSizeMake((screenSize.width-4) / 4.f - 4, (screenSize.width-4) / 4.f - 4);
        self.minimumLineSpacing = 4;
        self.sectionInset = UIEdgeInsetsMake(4, 4, 4, 4);
    }
    return self;
}
@end
