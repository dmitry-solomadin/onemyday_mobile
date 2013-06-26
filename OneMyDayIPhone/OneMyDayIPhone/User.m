//
//  User.m
//  OneMyDayIPhone
//
//  Created by dmitry.solomadin on 11.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "User.h"

@implementation User
@synthesize userId, name, avatarUrls, followedBySize, followersSize, storiesSize;

- (id)initWithId:(int)_userId andName:(NSString *)_name andAvatarUrls:(NSDictionary *)_avatarUrls andFollowedBySize:
    (int)_followedBySize andFollowersSize: (int)_followersSize andStoriesSize:(int)_storiesSize
{
    self = [super init];
    if (self) {
        self.userId = _userId;
        self.name = _name;
        self.avatarUrls = _avatarUrls;
        self.followersSize = _followersSize;
        self.followedBySize = _followedBySize;
        self.storiesSize = _storiesSize;
    }
    return self;
}

- (id)extractAvatarUrlType:(NSString *)type
{
    NSString *image = (NSString*) [avatarUrls objectForKey:type];
    NSURL *url = [NSURL URLWithString: image];
    return url;
}

- (id)extractAvatarStringType:(NSString *)type
{
    NSString *image = (NSString*) [avatarUrls objectForKey:type];  
    return image;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.avatarUrls forKey:@"avatarUrls"];
	[coder encodeInt32:self.userId forKey:@"userId"];
    [coder encodeInt32:self.followedBySize forKey:@"followedBySize"];
    [coder encodeInt32:self.followersSize forKey:@"followersSize"];
    [coder encodeInt32:self.storiesSize forKey:@"storiesSize"];
}


-(id)initWithCoder:(NSCoder *)coder {
	if ((self = [super init]))
	{
        self.name = [coder decodeObjectForKey:@"name"];
        self.avatarUrls = [coder decodeObjectForKey:@"avatarUrls"];
        self.userId = [coder decodeInt32ForKey:@"userId"];
        self.followedBySize = [coder decodeInt32ForKey:@"followedBySize"];
        self.followersSize = [coder decodeInt32ForKey:@"followersSize"];
        self.storiesSize = [coder decodeInt32ForKey:@"storiesSize"];
 	}
	return self;
}
 

@end
