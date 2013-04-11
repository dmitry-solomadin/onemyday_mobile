//
//  Story.m
//  OneMyDayIPhone
//
//  Created by Admin on 2/9/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "Story.h"

@implementation Story

@synthesize storyId, authorId, title, photos;

- (id)initWithId:(int)_storyId andTitle:(NSString*)_title
       andAuthor:(int)_author_id andPhotos: (NSArray*)_photos
{
    self = [super init];
    if (self) {
        self.storyId = _storyId;
        self.title = _title;
        self.authorId = _author_id;
        self.photos = _photos;
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

@end
