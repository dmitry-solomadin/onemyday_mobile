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

NSString *userStorePath = @"~/Documents/users";

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
    bool exists = false;
    for(int i = 0;i < [users count];i++){
        if([[users objectAtIndex:i] userId] == [user userId]){
            exists = true;
            break;
        }
    }
    if(!exists) [users addObject:user];
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
    NSDictionary *jsonData = [request getDataFrom: path requestData: nil];
    
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

- (void)saveUsersToDisk
{    
    userStorePath = [userStorePath stringByExpandingTildeInPath];
    
    NSMutableDictionary *rootObject;
    rootObject = [NSMutableDictionary dictionary];
    
    [rootObject setValue:users forKey:@"users"];
    
    [NSKeyedArchiver archiveRootObject:rootObject toFile: userStorePath];
}

- (void)loadUsersFromDisk
{
    userStorePath = [userStorePath stringByExpandingTildeInPath];
    
    NSMutableDictionary *rootObject;
    rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile: userStorePath];
    
    if ([rootObject valueForKey:@"users"] != nil) {
        users = [rootObject valueForKey:@"users"];
    }
}

@end
