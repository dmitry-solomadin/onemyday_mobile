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
    //NSLog(@"userData %@", userData);
    int userId = [(NSString *) [userData objectForKey:@"id"] intValue];
    NSString *name = (NSString *) [userData objectForKey:@"name"];
    NSDictionary *avatar_urls = (NSDictionary*) [userData objectForKey:@"avatar_urls"];
    int followedBySize = [(NSString *) [userData objectForKey:@"followed_by_size"] intValue];
    int followersSize = [(NSString *) [userData objectForKey:@"followers_size"] intValue];
    int storiesSize = [(NSString *) [userData objectForKey:@"stories_size"] intValue];
    
    return [[User alloc] initWithId:(int)userId andName:(NSString *)name andAvatarUrls:(NSDictionary *)avatar_urls andFollowedBySize:(int)followedBySize andFollowersSize: (int)followersSize
                     andStoriesSize:(int)storiesSize];
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
        NSArray *oldUsers = [rootObject valueForKey:@"users"];
        if(users != nil && [users count] > 0){
            for(int i= 0; i < [oldUsers count]; i++){
                [users addObject:[oldUsers objectAtIndex:i]];
            }
        }
        else users = oldUsers;
    }
}

+ (BOOL)isAvatarEmpty:(NSString *)avatarURL
{
    /// NSLog(@"%@", avatarURL);
    if ([avatarURL rangeOfString:@"no-avatar" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return YES;
    }
    return NO;
}

@end
