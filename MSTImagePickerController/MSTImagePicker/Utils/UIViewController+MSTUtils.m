//
//  UIViewController+Utils.m
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/13.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "UIViewController+MSTUtils.h"

@implementation UIViewController (MSTUtils)

- (void)addNavigationRightCancelButton {
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(mp_cancelButtonDidClicked)];
    self.navigationItem.rightBarButtonItem = right;
}

- (void)mp_cancelButtonDidClicked {
    
}

- (UIAlertController *)addAlertControllerWithTitle:(NSString *)title actionTitle:(NSString *)actionTitle {
    UIAlertController *alertCtrler = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:nil];
    [alertCtrler addAction:action];
    
    return alertCtrler;
}
@end
