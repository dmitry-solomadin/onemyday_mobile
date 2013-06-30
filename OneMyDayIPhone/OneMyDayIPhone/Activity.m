//
//  Activity.m
//  Onemyday
//
//  Created by Admin on 6/27/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "Activity.h"

@implementation Activity

@synthesize storyId, authorId, trackableType, reason, createdAt;

- (id)initWithId:(int)_storyId andTrackableType:(NSString*)_trackableType andReason:(NSString*)_reason
       andAuthor:(int)_authorId updatedAt:(NSDate *)_createdAt
{
    self = [super init];
    if (self) {
        self.storyId = _storyId;
        self.trackableType = _trackableType;
        self.authorId = _authorId;
        self.reason = _reason;
        self.createdAt = _createdAt;
    }
    return self;

}

@end
