//
//  Story.h
//  OneMyDayIPhone
//
//  Created by Admin on 2/9/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Story : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *photos;
@property int storyId;

- (id)initWithId:(int)storyId andTitle:(NSString*)title andPhotos: (NSArray*)photos;
- (id)extractPhotoUrlType:(NSString*)type atIndex:(int)index;

@end
