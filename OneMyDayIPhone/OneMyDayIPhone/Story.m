//
//  Story.m
//  OneMyDayIPhone
//
//  Created by Admin on 2/9/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "Story.h"

@implementation Story

@synthesize storyId, authorId, title, photos, createdAt, viewsCount, commentsCount, likesCount, isLikedByUser;

- (id)initWithId:(int)_storyId andTitle:(NSString*)_title
       andAuthor:(int)_author_id andPhotos: (NSArray*)_photos
    andCreatedAt:(NSDate *)_createdAt andViewsCount:(int)_viewsCount
andCommentsCount:(int)_commentsCount andLikesCount:(int)_likesCount isLikedByUser:(int)_isLikedByUser
{
    self = [super init];
    if (self) {
        self.storyId = _storyId;
        self.title = _title;
        self.authorId = _author_id;
        self.photos = _photos;
        self.createdAt = _createdAt;
        self.viewsCount = _viewsCount;
        self.commentsCount = _commentsCount;
        self.likesCount = _likesCount;        
        if(_isLikedByUser == 1)isLikedByUser = true;
        else isLikedByUser = false;
        NSLog(@"_isLikedByUser %d", _isLikedByUser);
        NSLog(@"isLikedByUser %d", isLikedByUser);
    }
    return self;
}

- (id)extractPhotoUrlType:(NSString *)type atIndex:(int)index
{
    NSDictionary *photo = [photos objectAtIndex: 0];
    NSDictionary *photo_urls = (NSDictionary *) [photo objectForKey:@"photo_urls"];
    NSString *image = (NSString*) [photo_urls objectForKey:type];
    NSURL *url = [NSURL URLWithString: image];
    return url;
}

- (id)extractPhotoStringType:(NSString *)type atIndex:(int)index
{
    NSDictionary *photo = [photos objectAtIndex: 0];
    NSDictionary *photo_urls = (NSDictionary *) [photo objectForKey:@"photo_urls"];
    NSString *image = (NSString*) [photo_urls objectForKey:type];
    return image;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.photos forKey:@"photos"];
    [coder encodeObject:self.createdAt forKey:@"createdAt"];
	[coder encodeInt32:self.storyId forKey:@"storyId"];
    [coder encodeInt32:self.authorId forKey:@"authorId"];
    [coder encodeInt32:self.viewsCount forKey:@"viewsCount"];
	[coder encodeInt32:self.commentsCount forKey:@"commentsCount"];
    [coder encodeInt32:self.likesCount forKey:@"likesCount"];
    [coder encodeBool:self.isLikedByUser forKey:@"isLikedByUser"];
}

- (id)initWithCoder:(NSCoder *)coder {
	if ((self = [super init])) {
        self.title = [coder decodeObjectForKey:@"title"];
        self.photos = [coder decodeObjectForKey:@"photos"];
        self.storyId = [coder decodeInt32ForKey:@"storyId"];
        self.authorId = [coder decodeInt32ForKey:@"authorId"];
        self.createdAt = [coder decodeObjectForKey:@"createdAt"];
        self.viewsCount = [coder decodeInt32ForKey:@"viewsCount"];
        self.commentsCount = [coder decodeInt32ForKey:@"commentsCount"];
        self.likesCount = [coder decodeInt32ForKey:@"likesCount"];
        self.isLikedByUser = [coder decodeBoolForKey:@"isLikedByUser"];
 	}
	return self;
}

@end
