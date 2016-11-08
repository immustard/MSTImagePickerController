//
//  MSTPickingModel.m
//  MSTImagePickerController
//
//  Created by Mustard on 2016/11/4.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "MSTPickingModel.h"

@implementation MSTPickingModel

- (NSString *)description {
    return self.debugDescription;
}

- (NSString *)debugDescription {
    id obj;
    if (self.image) obj = self.image;
    if (self.livePhoto) obj = self.livePhoto;
    if (self.videoURL) obj = self.videoURL;
    
    return [NSString stringWithFormat:@"<%@: %p> id: %@ | type: %zi | content: %@", [self class], self, self.identifier, self.type, obj];
}
@end
