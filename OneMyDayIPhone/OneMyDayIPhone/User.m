//
//  User.m
//  OneMyDayIPhone
//
//  Created by dmitry.solomadin on 11.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "User.h"

@implementation User
@synthesize userId, name, avatarUrls;

- (id)initWithId:(int)_userId andName:(NSString *)_name andAvatarUrls:(NSDictionary *)_avatarUrls
{
    self = [super init];
    if (self) {
        self.userId = _userId;
        self.name = _name;
        self.avatarUrls = _avatarUrls;
    }
    return self;
}

- (id)extractAvatarUrlType:(NSString *)type
{
    NSString *image = (NSString*) [avatarUrls objectForKey:type];
    NSURL *url = [NSURL URLWithString: image];
    return url;
}

@end
