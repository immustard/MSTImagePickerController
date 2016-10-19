//
//  NSDate+MSTUtils.m
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/18.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "NSDate+MSTUtils.h"

@implementation NSDate (MSTUtils)

- (NSString *)stringByPhotosMomentsType:(MSTImageMomentGroupType)type {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    
    switch (type) {
        case MSTImageMomentGroupTypeYear:
            //年
            [dateFormatter setDateFormat:@"YYYY"];
            break;
        case MSTImageMomentGroupTypeMonth:
            //月
            if ([[NSLocale currentLocale].localeIdentifier isEqualToString:@"zh-CN"]) {
                [dateFormatter setDateFormat:@"YYYY MMMM"];
            } else {
                [dateFormatter setDateFormat:@"MMMM YYYY"];
            }
            [dateFormatter setLocale:[NSLocale currentLocale]];
            break;
        case MSTImageMomentGroupTypeDay:
            //日
            [dateFormatter setDateStyle:NSDateFormatterFullStyle];
            [dateFormatter setLocale:[NSLocale currentLocale]];
            break;
        default:
            break;
    }

    return [dateFormatter stringFromDate:self];
}

@end
