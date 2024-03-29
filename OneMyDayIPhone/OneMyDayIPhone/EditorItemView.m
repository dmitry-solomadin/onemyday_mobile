//
//  EditorItemView.m
//  Onemyday
//
//  Created by dmitry.solomadin on 29.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "EditorItemView.h"

@implementation EditorItemView
@synthesize type, key, originX, originY;

- (id)initWithFrame:(CGRect)frame andType:(ItemType)_type andKey:(NSString *)_key
{
    self = [super initWithFrame:frame];
    if (self) {
        type = _type;
        key = _key;
        originX = frame.origin.x;
        originY = frame.origin.y;
    }
    return self;
}

@end
