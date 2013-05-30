//
//  ThumbStoryDetailsView.h
//  Onemyday
//
//  Created by dmitry.solomadin on 17.05.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Story;

@interface ThumbStoryDetailsView : UIView

@property (nonatomic, strong) Story *story;

- (id)initWithFrame:(CGRect)frame story:(Story *)_story;

@end
