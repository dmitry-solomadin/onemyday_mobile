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
    return [self requestUserWithId:userId];
}

- (User *)requestUserWithId:(int)userId
{
    NSString *path = [NSString stringWithFormat:@"/users/%d.json", userId];
    Request *request = [[Request alloc] init];
    NSDictionary *jsonData = [request send:path];
    NSDictionary *userData = [jsonData objectForKey:@"user"];
    User *user = [self parseUserData:userData];
    [self addOrReplaceUser:user];    
    return user;
}

- (void)addOrReplaceUser:(User *)user
{
    bool exists = false;
    for(int i = 0;i < [users count];i++){
        if([[users objectAtIndex:i] userId] == [user userId]){
            exists = true;        
            [users replaceObjectAtIndex:i withObject:user];
            break;
        }
    }
    if(!exists) [users addObject:user];
}

- (User *)parseUserData:(NSDictionary *)userData
{
    int userId = [(NSString *) [userData objectForKey:@"id"] intValue];
    NSString *name = (NSString *) [userData objectForKey:@"name"];
    NSString *email = (NSString *) [userData objectForKey:@"email"];
    NSString *gender = (NSString *) [userData objectForKey:@"gender"];
    NSDictionary *avatar_urls = (NSDictionary*) [userData objectForKey:@"avatar_urls"];
    int followedBySize = [(NSString *) [userData objectForKey:@"followed_by_size"] intValue];
    int followersSize = [(NSString *) [userData objectForKey:@"followers_size"] intValue];
    int storiesSize = [(NSString *) [userData objectForKey:@"stories_size"] intValue];
    
    return [[User alloc] initWithId:userId andName:name andAvatarUrls:avatar_urls andFollowedBySize:followedBySize andFollowersSize: followersSize andStoriesSize:storiesSize andEmail: email andGender: gender];
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
                [self addUser:[oldUsers objectAtIndex:i]];
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
