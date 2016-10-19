//
//  NSDate+MSTUtils.h
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/18.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSTPhotoConfiguration.h"

@interface NSDate (MSTUtils)

/**
 根据分组方式，生成对应字符串
 
 @param type 分组方式
 
 */
- (NSString *)stringByPhotosMomentsType:(MSTImageMomentGroupType)type;

@end
