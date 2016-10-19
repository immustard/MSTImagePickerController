//
//  UICollectionView+Utils.m
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/14.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "UICollectionView+MSTUtils.h"

@implementation UICollectionView (MSTUtils)

- (NSArray *)indexPathsForElementsInRect:(CGRect)rect {
    NSArray *allLayoutAttributes = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
    
    if (allLayoutAttributes.count == 0) return nil;
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    
    return indexPaths;
}

@end
