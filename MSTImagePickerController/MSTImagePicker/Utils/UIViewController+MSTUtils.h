//
//  UIViewController+Utils.h
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/13.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (MSTUtils)

- (void)addNavigationRightCancelButton;

- (UIAlertController *)addAlertControllerWithTitle:(NSString *)title actionTitle:(NSString *)actionTitle;
@end
