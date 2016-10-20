//
//  MSTAlbumModel.m
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/13.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "MSTAlbumModel.h"

@implementation MSTAlbumModel

- (NSUInteger)count {
    return self.content.count;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> albumName:%@ | count:%zi", [self class], self, self.albumName, self.count];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p> albumName:%@ | count:%zi", [self class], self, self.albumName, self.count];
}

@end
