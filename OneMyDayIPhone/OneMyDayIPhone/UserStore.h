//
//  UserStore.h
//  OneMyDayIPhone
//
//  Created by dmitry.solomadin on 11.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface UserStore : NSObject
{
    NSMutableArray *users;
}

+ (UserStore *)get;
+ (BOOL)isAvatarEmpty:(NSString *)avatarURL;

- (void)setUsers:(NSMutableArray *)_users;
- (NSArray *)getUsers;
- (void) addUser:(User *)user;
- (User *)findById:(int)userId;
- (User *)requestUserWithId:(int)userId;
- (User *)parseUserData:(NSDictionary *)userData;
- (void)saveUsersToDisk;
- (void)loadUsersFromDisk;
- (void)addOrReplaceUser:(User *)user;


@end
