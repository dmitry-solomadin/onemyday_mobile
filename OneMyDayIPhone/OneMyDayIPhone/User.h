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

- (id)initWithId:(int)_userId andName:(NSString *)name andAvatarUrls:(NSDictionary *)avatarUrls;
- (id)extractAvatarUrlType:(NSString *)type;
- (id)extractAvatarStringType:(NSString *)type;

@end
