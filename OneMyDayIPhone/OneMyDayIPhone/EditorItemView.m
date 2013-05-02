//
//  EditorItemView.m
//  Onemyday
//
//  Created by dmitry.solomadin on 29.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "EditorItemView.h"

@implementation EditorItemView
@synthesize type;

- (id)initWithFrame:(CGRect)frame andType:(ItemType)_type
{
    self = [super initWithFrame:frame];
    if (self) {
        type = _type;
    }
    return self;
}

@end
