//
//  ActivityView.m
//  Onemyday
//
//  Created by Admin on 6/27/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "ActivityView.h"
#import "Activity.h"
#import "StoryCommentView.h"
#import "User.h"
#import "AsyncImageView.h"
#import "UserStore.h"
#import "TTTTimeIntervalFormatter.h"
#import <QuartzCore/QuartzCore.h>
#import "Request.h"
#import "AppDelegate.h"
#import "StoryStore.h"

@implementation ActivityView

@synthesize controller;

NSMutableAttributedString *str;
int authorId;
int storyId;
NSString *authorName = @"qwe";
NSString *message;
NSString *storyTitle;

- (id)initWithFrame:(CGRect)frame andActivity: (NSDictionary *) activity
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //container
        UIView *activityContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 60)];
        [activityContainerView setBackgroundColor:[UIColor whiteColor]];
        activityContainerView.layer.cornerRadius = 10.0;
        activityContainerView.layer.borderColor = [[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1] CGColor];
        activityContainerView.layer.borderWidth = 1;
        [self addSubview:activityContainerView];
        
       
        
        // Author name
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(55, 0, 240, 55)];
        [textView setText:@"ffdsf qwe eee"];
        [textView setBackgroundColor:[UIColor clearColor]];
        [textView setFont:[UIFont fontWithName:@"Helvetica" size:14]];
        //[textView setTextColor:[UIColor colorWithRed:63/255.f green:114/255.f blue:155/255.f alpha:1]];
        
        [textView setEditable:NO];
         
        [activityContainerView addSubview:textView];
        
        //activity data
        int avtivityId = [(NSString *) [activity objectForKey:@"id"] intValue];
        NSString *trackableType = (NSString *) [activity objectForKey:@"trackable_type"];
        NSString *reason = (NSString *) [activity objectForKey:@"reason"];
        int trackableId = [(NSString *) [activity objectForKey:@"trackable_id"] intValue];
        NSDictionary *object;
        
        //message for comment
        if([trackableType isEqualToString: @"Comment"]){
            object = (NSDictionary *)[activity objectForKey:@"comment"];
            if(object == nil)return nil;           
            
            storyId = [(NSString *) [object objectForKey:@"story_id"] intValue];
            authorName = (NSString *) [object objectForKey:@"author_name"];
           
            storyTitle = (NSString *) [object objectForKey:@"story_title"];
            
            NSMutableString *text;
            if([[object objectForKey:@"text"] isKindOfClass:[NSArray class]]){                
                NSArray *msgArray = [object objectForKey:@"text"];                
                for(int i = 0; i < [msgArray count]; i++){
                    [text appendString:[msgArray objectAtIndex:i]];
                }
            }
            else if([[object objectForKey:@"text"] isKindOfClass:[NSString class]]){
               text = [object objectForKey:@"text"];
            }
            //Activity message           
            if([reason isEqualToString:@"regular"]){            
                message = [NSString stringWithFormat:@"%@  has added a comment to your %@ story. That's what he wrote: %@",authorName, storyTitle, text];     
            } else {
                message = [NSString stringWithFormat:@"%@  has left a comment on a story you commented on %@ That's what he wrote: %@",authorName, storyTitle, text];              
            }
            
            //Colored string
            str = [[NSMutableAttributedString alloc] initWithString:message];
            NSRange authorRange = [message rangeOfString: authorName];
            NSRange storyRange = [message rangeOfString: storyTitle];
            [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-Bold" size:14] range:authorRange];
            [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-Bold" size:14] range:storyRange];
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:63/255.f green:114/255.f blue:155/255.f alpha:1] range:authorRange];
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:63/255.f green:114/255.f blue:155/255.f alpha:1] range:storyRange];
            
        //message for like
        } else if([trackableType isEqualToString: @"Like"]){
            object = (NSDictionary *)[activity objectForKey:@"like"];
            authorName = (NSString *) [object objectForKey:@"author_name"];
            storyTitle = (NSString *) [object objectForKey:@"story_title"];
            message = [NSString stringWithFormat:@"%@ has liked your %@ story", authorName, storyTitle];
            str = [[NSMutableAttributedString alloc] initWithString:message];
            NSRange authorRange = [message rangeOfString: authorName];
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:63/255.f green:114/255.f blue:155/255.f alpha:1] range:authorRange];
            [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-Bold" size:14] range:authorRange];
         //message for user
        } else if([trackableType isEqualToString: @"User"]){
            object = (NSDictionary *)[activity objectForKey:@"user"];
            authorName = (NSString *) [object objectForKey:@"author_name"];       
            message = [NSString stringWithFormat:@"You have a new follower %@ ", authorName];
            str = [[NSMutableAttributedString alloc] initWithString:message];
            NSRange authorRange = [message rangeOfString: authorName];
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:63/255.f green:114/255.f blue:155/255.f alpha:1] range:authorRange];
            [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-Bold" size:14] range:authorRange];
            
        //message for story
        } else if([trackableType isEqualToString: @"Story"]){            
            object = (NSDictionary *)[activity objectForKey:@"story"];
            
            storyId = trackableId;
            authorName = (NSString *) [object objectForKey:@"author_name"];
            
            storyTitle = (NSString *) [object objectForKey:@"story_title"];
            
            message = [NSString stringWithFormat:@"%@   has liked your %@ story",authorName, storyTitle];
            
            //Colored string
            str = [[NSMutableAttributedString alloc] initWithString:message];
            NSRange authorRange = [message rangeOfString: authorName];
            NSRange storyRange = [message rangeOfString: storyTitle];
            [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-Bold" size:14] range:authorRange];
            [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-Bold" size:14] range:storyRange];
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:63/255.f green:114/255.f blue:155/255.f alpha:1] range:authorRange];
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:63/255.f green:114/255.f blue:155/255.f alpha:1] range:storyRange];
            
        } else str = [[NSMutableAttributedString alloc] initWithString:@"qwe"];
        
        //NSLog(@"object %@", object);
        
        int authorId = [(NSString *) [object objectForKey:@"author_id"] intValue];
    
       
        NSDate *createdAt = [StoryStore parseRFC3339Date:[activity objectForKey:@"created_at"]];        
        
       // NSLog(@"authorId  %d", authorId);
        
        // Author avatar
        User *author = [[UserStore get] findById: authorId];     
        AsyncImageView *avatarView = [[AsyncImageView alloc] initWithFrame: CGRectMake(5, 5, 50, 50)];
        avatarView.clipsToBounds = YES;
        avatarView.layer.cornerRadius = 10;
        avatarView.layer.borderColor = [[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] CGColor];
        avatarView.layer.borderWidth = 1;
        avatarView.layer.backgroundColor = [[UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1] CGColor];
        avatarView.showActivityIndicator = NO;
        
        NSURL *avatarUrl = [author extractAvatarUrlType:@"small_url"];
        if ([UserStore isAvatarEmpty:[avatarUrl absoluteString]]) {
            [avatarView setImage:[UIImage imageNamed:@"no-avatar"]];
        } else {
            [avatarView setImageURL:avatarUrl];
        }
        
        [activityContainerView addSubview:avatarView];
        
        self.tag = avtivityId;
        
        textView.attributedText = str;
        [textView sizeToFit];
        textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, 240, textView.contentSize.height);        
        
        //author name frame
        CGRect linkAuthorFrame = [self frameOfTextRange:[[textView text] rangeOfString: authorName] inTextView:textView];
        
        //author name button
        UIButton *authorBtn = [[UIButton alloc] initWithFrame: CGRectMake(linkAuthorFrame .origin.x+55, linkAuthorFrame.origin.y, linkAuthorFrame.size.width, linkAuthorFrame.size.height)];
        authorBtn.tag = authorId;
        [authorBtn addTarget:self action:@selector(authorBtnTap:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:authorBtn];
        [self bringSubviewToFront:authorBtn];
        
        //author avatar button
        UIButton *authorAvatarBtn = [[UIButton alloc] initWithFrame: CGRectMake(5, 5, 50, 50)];
        authorAvatarBtn.tag = authorId;
        [authorAvatarBtn addTarget:self action:@selector(authorBtnTap:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:authorAvatarBtn];
        [self bringSubviewToFront:authorAvatarBtn];
        
        // story button
        if(storyTitle != nil){         
            CGRect linkStoryFrame = [self frameOfTextRange:[[textView text] rangeOfString: storyTitle] inTextView:textView];
           
            UIButton *storyBtn = [[UIButton alloc] initWithFrame: CGRectMake(linkStoryFrame.origin.x+55, linkStoryFrame .origin.y, linkStoryFrame.size.width, linkStoryFrame.size.height)];
            storyBtn.tag = storyId;
            [storyBtn addTarget:self action:@selector(storyBtnTap:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:storyBtn];
            [self bringSubviewToFront:storyBtn];
        }
       
        
        // Time created
        TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        NSString *time = [timeIntervalFormatter stringForTimeInterval:[createdAt timeIntervalSinceNow]];
        
        CGFloat timeY = 43;
        if(textView.contentSize.height > 55)timeY = textView.contentSize.height - 7;
        
        UILabel *timeAgoLabel = [[UILabel alloc] initWithFrame:CGRectMake(300, 15, 0, 35)];
        [timeAgoLabel setText:time];
        [timeAgoLabel setBackgroundColor:[UIColor clearColor]];
        [timeAgoLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
        [timeAgoLabel setTextColor:[UIColor grayColor]];
        [timeAgoLabel sizeToFit];
        //NSLog(@"%f", timeAgoLabel.frame.size.width);
        timeAgoLabel.frame = CGRectMake(290 - timeAgoLabel.frame.size.width, timeY,
                                        timeAgoLabel.frame.size.width, timeAgoLabel.frame.size.height);
        [activityContainerView addSubview:timeAgoLabel];
        
               if(textView.contentSize.height > 55){
            activityContainerView.frame = CGRectMake(activityContainerView.frame.origin.x, activityContainerView.frame.origin.y, 300, textView.contentSize.height + 10);
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 300, textView.contentSize.height + 10 );
            [timeAgoLabel bringSubviewToFront:activityContainerView];
        }       
    }
    return self;
}


- (CGRect)frameOfTextRange:(NSRange)range inTextView:(UITextView *)textView
{
    UITextPosition *beginning = textView.beginningOfDocument; //Error=: request for member 'beginningOfDocument' in something not a structure or union
    
    UITextPosition *start = [textView positionFromPosition:beginning offset:range.location];
    UITextPosition *end = [textView positionFromPosition:start offset:range.length];
    UITextRange *textRange = [textView textRangeFromPosition:start toPosition:end];
    CGRect rect = [textView firstRectForRange:textRange];  //Error: Invalid Intializer
    
    return [textView convertRect:rect fromView:textView.textInputView]; // Error: request for member 'textInputView' in something not a structure or union
    //return rect;
}

- (void)authorBtnTap:(UIButton *)sender
{
    NSLog(@" sender %d", sender.tag);
    NSNumber *authorId = [NSNumber numberWithInteger:sender.tag];
    [[self controller] performSelector:@selector(authorOfStorieTap:) withObject:authorId];
}

- (void)storyBtnTap:(UIButton *)sender
{    
    NSNumber *storyId = [NSNumber numberWithInteger:sender.tag];
    [[self controller] performSelector:@selector(editBtnTap:) withObject:storyId];
}

@end
