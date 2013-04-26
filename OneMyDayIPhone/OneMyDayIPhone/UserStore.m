//
//  UserStore.m
//  OneMyDayIPhone
//
//  Created by dmitry.solomadin on 11.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "UserStore.h"
#import "User.h"
#import "Request.h"

@implementation UserStore

+ (UserStore *)get
{
    static UserStore *store = nil;
    if (!store) {
        store = [[super allocWithZone:nil] init];
        store.users = [[NSMutableArray alloc] init];
    }
    
    return store;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self get];
}

- (NSArray *)getUsers;
{
    return users;
}

- (void)setUsers:(NSMutableArray *)_users
{
    users = _users;
}

- (void)addUser:(User *)user
{
    [users addObject:user];
}

- (User *)findById:(int)userId
{
    for (User *user in users) {
        if (user.userId == userId) {
            return user;
        }
    }
    return nil;
}

- (User *)requestUserWithId:(int)userId
{
    NSString *path = [NSString stringWithFormat:@"/users/%d.json", userId];
    Request *request = [[Request alloc] init];
    NSDictionary *jsonData = [request getDataFrom: path];
    
    User *user = [self parseUserData:jsonData];
    [self addUser:user];
    
    return user;
}

- (User *)parseUserData:(NSDictionary *)userData
{
    int userId = [(NSString *) [userData objectForKey:@"id"] intValue];
    NSString *name = (NSString *) [userData objectForKey:@"name"];
    NSDictionary *avatar_urls = (NSDictionary*) [userData objectForKey:@"avatar_urls"];
    
    return [[User alloc] initWithId:userId andName:name andAvatarUrls:avatar_urls];
}

- (void)saveUsersToDisk: (NSMutableArray *)stories {
    NSString *path = @"~/Documents/data";
    path = [path stringByExpandingTildeInPath];
    
    NSMutableDictionary *rootObject;
    rootObject = [NSMutableDictionary dictionary];
    
    [rootObject setValue:stories forKey:@"users"];
    
    [NSKeyedArchiver archiveRootObject:rootObject toFile:path];
}

- (void)loadUsersFromDisk {
    NSString *path = @"~/Documents/data";
    path = [path stringByExpandingTildeInPath];
    
    NSMutableDictionary *rootObject;
    rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];    
    
    users = [rootObject valueForKey:@"users"];
}


@end
