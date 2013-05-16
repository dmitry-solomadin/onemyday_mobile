//
//  Story.h
//  OneMyDayIPhone
//
//  Created by Admin on 2/9/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Story : NSObject<NSCoding> 

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *photos;
@property int storyId;
@property int authorId;
@property NSDate *createdAt;

- (id)initWithId:(int)storyId andTitle:(NSString*)title
       andAuthor:(int)author_id andPhotos: (NSArray*)photos
    andCreatedAt:(NSDate *)_createdAt;
- (id)extractPhotoUrlType:(NSString*)type atIndex:(int)index;
- (id)extractPhotoStringType:(NSString*)type atIndex:(int)index;
@end
