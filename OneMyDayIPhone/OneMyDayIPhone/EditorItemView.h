//
//  EditorItemView.h
//  Onemyday
//
//  Created by dmitry.solomadin on 29.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditorStore.h"

@interface EditorItemView : UIView

- (id)initWithFrame:(CGRect)frame andType:(ItemType)_type andKey:(NSString *)_key;

@property (nonatomic) ItemType *type;
@property (nonatomic) NSString *key;

@end
