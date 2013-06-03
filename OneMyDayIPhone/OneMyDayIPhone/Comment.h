//
//  Comment.h
//  Onemyday
//
//  Created by Admin on 6/2/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject

@property (nonatomic, strong) NSString *text;
@property int storyId;
@property int authorId;
@property int commentId;
@property NSDate *createdAt;
@property NSDate *updatedAt;

- (id)initWithId:(int)_storyId andText:(NSString*)_text
       andAuthor:(int)_authorId andCreatedAt:(NSDate *)_createdAt
       updatedAt:(NSDate *)_updatedAt andCommentId:(int)_commentId;

@end
