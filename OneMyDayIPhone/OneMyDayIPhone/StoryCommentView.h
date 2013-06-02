//
//  StoryCommentView.h
//  Onemyday
//
//  Created by Admin on 6/2/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"

@interface StoryCommentView : UIView

@property (nonatomic, weak) id controller;

- (id)initWithFrame:(CGRect)frame andComment:(Comment *)comment;

@end
