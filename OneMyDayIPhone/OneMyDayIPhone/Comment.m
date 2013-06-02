//
//  Comment.m
//  Onemyday
//
//  Created by Admin on 6/2/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "Comment.h"

@implementation Comment

@synthesize storyId, authorId, text, createdAt, updatedAt, commentId;

- (id)initWithId:(int)_storyId andText:(NSString*)_text
       andAuthor:(int)_authorId andCreatedAt:(NSDate *)_createdAt
   updatedAt:(NSDate *)_updatedAt andCommentId:(int)_commentId
{
    self = [super init];
    if (self) {
        self.storyId = _storyId;
        self.text = _text;
        self.authorId = _authorId;
        self.updatedAt = _updatedAt;
        self.createdAt = _createdAt;
        self.commentId = _commentId;
     
        NSLog(@"storyId %d", storyId);
        NSLog(@"text %@", text);
        NSLog(@"author_id %d", _authorId);
        NSLog(@"author_id %@", _updatedAt);
        NSLog(@"author_id %@", _createdAt);
        NSLog(@"author_id %d", _commentId);
    }
    return self;
}

@end
