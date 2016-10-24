//
//  NSIndexSet+Utils.m
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/14.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSIndexSet+MSTUtils.h"

@implementation NSIndexSet (MSTUtils)

- (NSArray *)indexPathsFromIndexesWithSection:(NSUInteger)section isShowCamera:(BOOL)isShowCamera {
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.count];
    
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        if (isShowCamera) idx++;
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
    }];
    
    return indexPaths;
}

@end
