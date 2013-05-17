//
//  Story.m
//  OneMyDayIPhone
//
//  Created by Admin on 2/9/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "Story.h"

@implementation Story

@synthesize storyId, authorId, title, photos, createdAt;

- (id)initWithId:(int)_storyId andTitle:(NSString*)_title
       andAuthor:(int)_author_id andPhotos: (NSArray*)_photos
    andCreatedAt:(NSDate *)_createdAt
{
    self = [super init];
    if (self) {
        self.storyId = _storyId;
        self.title = _title;
        self.authorId = _author_id;
        self.photos = _photos;
        self.createdAt = _createdAt;
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
}

- (id)initWithCoder:(NSCoder *)coder {
	if ((self = [super init])) {
        self.title = [coder decodeObjectForKey:@"title"];
        self.photos = [coder decodeObjectForKey:@"photos"];
        self.storyId = [coder decodeInt32ForKey:@"storyId"];
        self.authorId = [coder decodeInt32ForKey:@"authorId"];
        self.createdAt = [coder decodeObjectForKey:@"createdAt"];
 	}
	return self;
}

@end
