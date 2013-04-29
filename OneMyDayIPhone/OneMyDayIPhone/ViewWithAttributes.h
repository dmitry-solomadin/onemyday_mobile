//
//  ViewWithAttributes.h
//  Onemyday
//
//  Created by dmitry.solomadin on 29.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewWithAttributes : UIView

@property (nonatomic, strong) NSMutableDictionary *attributes;
@property (nonatomic, strong) NSString *identity;

- (void)addAttribute:(id)attr forKey:(NSString *)key;
- (id)getAttributeForKey:(NSString *)key;

@end
