//
//  User.h
//  OneMyDayIPhone
//
//  Created by dmitry.solomadin on 11.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property int userId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDictionary *avatarUrls;
@property int followedBySize;
@property int followersSize;
@property int storiesSize;

- (id)initWithId:(int)_userId andName:(NSString *)_name andAvatarUrls:(NSDictionary *)_avatarUrls andFollowedBySize:
    (int)followedBySize andFollowersSize: (int)followersSize andStoriesSize:(int)storiesSize;
- (id)extractAvatarUrlType:(NSString *)type;
- (id)extractAvatarStringType:(NSString *)type;

@end
