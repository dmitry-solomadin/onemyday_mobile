//
//  Activity.h
//  Onemyday
//
//  Created by Admin on 6/27/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Activity : NSObject

@property int storyId;
@property int authorId;
@property (nonatomic, strong) NSString *trackableType;
@property (nonatomic, strong) NSString *reason;
@property (nonatomic, strong) NSDate *createdAt;

- (id)initWithId:(int)_storyId andTrackableType:(NSString*)_trackableType andReason:(NSString*)_reason
andAuthor:(int)_authorId updatedAt:(NSDate *)_createdAt;

@end
