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

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.avatarUrls forKey:@"avatarUrls"];
	[coder encodeInt32:self.userId forKey:@"userId"];}


-(id)initWithCoder:(NSCoder *)coder {
	if ((self = [super init]))
	{
        self.name = [coder decodeObjectForKey:@"name"];
        self.avatarUrls = [coder decodeObjectForKey:@"avatarUrls"];
        self.userId = [coder decodeInt32ForKey:@"userId"];
 	}
	return self;
}
 

@end
