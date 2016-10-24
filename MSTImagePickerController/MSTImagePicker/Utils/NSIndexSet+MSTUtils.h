//
//  NSIndexSet+Utils.h
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/14.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexSet (MSTUtils)

- (NSArray *)indexPathsFromIndexesWithSection:(NSUInteger)section isShowCamera:(BOOL)isShowCamera;;

@end
