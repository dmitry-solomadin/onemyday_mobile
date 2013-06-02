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
@property int viewsCount;
@property int commentsCount;
@property int likesCount;
@property bool isLikedByUser;
@property NSDate *createdAt;

- (id)initWithId:(int)_storyId andTitle:(NSString*)_title
       andAuthor:(int)_author_id andPhotos: (NSArray*)_photos
    andCreatedAt:(NSDate *)_createdAt andViewsCount:(int)_viewsCount
andCommentsCount:(int)_commentsCount andLikesCount:(int)_likesCount isLikedByUser:(int)_isLikedByUser;
- (id)extractPhotoUrlType:(NSString*)type atIndex:(int)index;
- (id)extractPhotoStringType:(NSString*)type atIndex:(int)index;
- (bool) isLikedByUser;
- (void) setIsLikedByUser: (bool) _isLikedByUser;
@end
