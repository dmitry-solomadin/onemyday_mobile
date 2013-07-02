//
//  PopupError.h
//  Onemyday
//
//  Created by dmitry.solomadin on 02.07.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopupError : UIView

- (id)initWithView:(UIView *)view;
- (void)setTextAndShow:(NSString *)text;
- (void)setText:(NSString *)text;
- (void)show;

@end
