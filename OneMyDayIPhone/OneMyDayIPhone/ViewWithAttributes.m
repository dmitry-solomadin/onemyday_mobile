//
//  ViewWithAttributes.m
//  Onemyday
//
//  Created by dmitry.solomadin on 29.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "ViewWithAttributes.h"

@implementation ViewWithAttributes
@synthesize attributes, identity;

- (id)initWithFrame:(CGRect)frame
{
    self = [self initWithFrame:frame andId:nil];
    return self;
}

- (id)initWithFrame:(CGRect)frame andId:(NSString *)_id
{
    self = [super initWithFrame:frame];
    if (self) {
        attributes = [[NSMutableDictionary alloc] init];
        identity = _id;
    }
    return self;
}

- (void)addAttribute:(id)attr forKey:(NSString *)key
{
    [attributes setObject:attr forKey:key];
}

- (id)getAttributeForKey:(NSString *)key
{
    return [attributes objectForKey:key];
}

@end
