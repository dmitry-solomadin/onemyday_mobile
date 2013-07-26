//
//  ShowStoryViewController.m
//  OneMyDayIPhone
//
//  Created by dmitry.solomadin on 10.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "ShowStoryViewController.h"
#import "Story.h"
#import "AsyncImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "Request.h"
#import "AppDelegate.h"
#import "StoryStore.h"
#import "StoryCommentView.h"
#import "ProfileViewController.h"
#import "UIApplication+NetworkActivity.h"
#import "PopupError.h"
#import "StoryLikeAreaView.h"

@interface ShowStoryViewController ()

@end

@implementation ShowStoryViewController
@synthesize story, scrollView;

AppDelegate *appDelegate;
CGFloat currentStoryHeight;

StoryLikeAreaView *storyLikeArea;

UIView *commentFormContainer;
UITextField *textField;

NSMutableArray *comments;
UIActivityIndicatorView *delCommentIndicator;
UIActivityIndicatorView *commentsIndicator;

PopupError *popupError;

- (id)initWithStory:(Story *)_story
{
    if (self = [super initWithNibName: nil bundle: nil]) {
        self.story = _story;
      
        appDelegate = [[UIApplication sharedApplication] delegate];
        
        [[self view] setFrame: self.view.window.bounds];
        
        scrollView = [[UIScrollView alloc] initWithFrame: CGRectZero];
        [scrollView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"cool_bg"]]];
        [[self view] addSubview:scrollView];
        
        currentStoryHeight = 10.0f;
        for (int i = 0; i < [[story photos] count]; i++) {
            // Add photo
            NSDictionary *photo = [[story photos] objectAtIndex:i];
            NSDictionary *photo_urls = (NSDictionary *) [photo objectForKey:@"photo_urls"];
            NSString *image = (NSString*) [photo_urls objectForKey:@"iphone2x_url"];
            
            NSDictionary *photo_dimensions = (NSDictionary *) [photo objectForKey:@"photo_dimensions"];
            NSDictionary *dimensions = (NSDictionary *) [photo_dimensions objectForKey:@"iphone2x"];
            NSNumber *height2x = [dimensions objectForKey:@"height"];
            float height = [height2x floatValue] / 2;

            if (image) {
                AsyncImageView *asyncImageView = [[AsyncImageView alloc] initWithFrame:
                                                  CGRectMake(10, currentStoryHeight, 300, height)];
                asyncImageView.contentMode = UIViewContentModeScaleAspectFit;
                
                NSURL *url = [NSURL URLWithString:image];
                asyncImageView.imageURL = url;
                
                [scrollView addSubview:asyncImageView];
                currentStoryHeight += height;
            }
            
            // Add text
            NSString *caption = (NSString *) [photo objectForKey:@"caption"];
            if (caption != ( NSString *) [ NSNull null ]) {
                UITextView *textView = [[UITextView alloc] init];
                textView.text = caption;
                [textView setEditable:NO];
                [textView setFont:[UIFont systemFontOfSize:15]];
                [textView sizeToFit];
                [textView setBackgroundColor:[UIColor clearColor]];
                [textView setContentInset:UIEdgeInsetsMake(0, -8, 0, 0)];
                [scrollView addSubview:textView];

                textView.frame = CGRectMake(10, currentStoryHeight, 300, textView.contentSize.height);
                [textView sizeToFit];
                currentStoryHeight += textView.contentSize.height;
            } else {
                currentStoryHeight += 10;
            }
        }
        
        storyLikeArea = [AppDelegate loadNibNamed:@"StoryLikeArea" ofClass:[StoryLikeAreaView class]];
        [storyLikeArea setController:self];
        storyLikeArea.frame = CGRectMake(-1, currentStoryHeight,
                                         storyLikeArea.frame.size.width, storyLikeArea.frame.size.height);
        storyLikeArea.clipsToBounds = YES;
        storyLikeArea.layer.borderColor = [[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1] CGColor];
        storyLikeArea.layer.borderWidth = 1;
        [scrollView addSubview:storyLikeArea];
        
        currentStoryHeight += 65;
        
        if([story isLikedByUser]){
            [storyLikeArea.button setImage:[UIImage imageNamed:@"liked_button"] forState:UIControlStateNormal];
         } else {
            [storyLikeArea.button setImage:[UIImage imageNamed:@"like_button"] forState:UIControlStateNormal];
        }
        [self setLikeTextCount:[story likesCount]];
        
        [self drawAddCommentForm];
        
        [self getStoryComments];
        
        [scrollView setContentSize:(CGSizeMake(320, currentStoryHeight))];
        [scrollView setAutoresizesSubviews:NO];
        
        // add popup error
        popupError = [[PopupError alloc] initWithView:self.view];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

/* STORY LIKES */

- (void)setLikeTextCount:(int)likesCount
{
    storyLikeArea.text.text = [NSString stringWithFormat:@"%d %@",
                               likesCount, NSLocalizedString(@"people likes this story", nil)];
    if (likesCount == 0) {
        storyLikeArea.text.hidden = true;
    } else {
        storyLikeArea.text.hidden = false;
    }
}

- (void)likeButtonTapped
{
    NSString *likeOrUnlike;
    if([story isLikedByUser])likeOrUnlike = @"unlike";
    else likeOrUnlike = @"like";
    NSMutableString *path = [NSString stringWithFormat:@"/api/stories/%d/%@", [story storyId], likeOrUnlike];
    
    [self doLikeTap];    
    
    Request *request = [[Request alloc] init];
    
    [[UIApplication sharedApplication] showNetworkActivityIndicator];    
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
    dispatch_async(downloadQueue, ^{        
        [request addStringToPostData:@"api_key" andValue:appDelegate.apiKey];
        [request addStringToPostData:@"user_id" andValue: [NSString stringWithFormat:@"%d",appDelegate.currentUserId]];
        [request send:path];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
            if([request errorMsg] != nil){
                [self doLikeTap];
                [appDelegate alertStatus:@"" :[request errorMsg]];
                return;
            }
        });
    });
}

- (void)doLikeTap
{
    if([story isLikedByUser]){
        [storyLikeArea.button setImage:[UIImage imageNamed:@"like_button"] forState:UIControlStateNormal];
        [story setLikesCount: [story likesCount] - 1];
        [story setIsLikedByUser:false];
    } else {
        [storyLikeArea.button setImage:[UIImage imageNamed:@"liked_button"] forState:UIControlStateNormal];
        [story setLikesCount: [story likesCount] + 1];
        [story setIsLikedByUser:true];
    }
    [self setLikeTextCount:[story likesCount]];
    [self performSelectorInBackground:@selector(saveLikeToCache) withObject:nil];
}

- (void)saveLikeToCache
{
    StoryStore *store = [StoryStore get];
    @synchronized (store) {
        NSMutableArray *cachedStories = [store getCachedStories];
        for(int i = 0; i < [cachedStories count]; i++){
            Story *cachedStory = [cachedStories objectAtIndex:i];
            if([story storyId] == [cachedStory storyId]){
                [cachedStory setIsLikedByUser:[story isLikedByUser]];
                [cachedStory setLikesCount: [story likesCount]];
                [cachedStories replaceObjectAtIndex:i withObject:cachedStory];
                [[StoryStore get] saveStoriesToDisk: cachedStories];
                break;
            }
        }
    }
}

/* STORY COMMENTS */

- (void)getStoryComments
{
    commentsIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    commentsIndicator.frame = CGRectMake(10, 45, 100, 40);
    commentsIndicator.center = CGPointMake(160, currentStoryHeight - 40);

    commentFormContainer.frame = CGRectMake(commentFormContainer.frame.origin.x, commentFormContainer.frame.origin.y + 40,
                                            commentFormContainer.frame.size.width, commentFormContainer.frame.size.height);
    currentStoryHeight += 40;
    
    commentsIndicator.hidesWhenStopped = YES;
    [scrollView addSubview: commentsIndicator];
    [commentsIndicator bringSubviewToFront: scrollView];
    [scrollView setContentSize: CGSizeMake(320, currentStoryHeight)];
    [commentsIndicator startAnimating];
    
    Request *request = [[Request alloc] init];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    dispatch_async(downloadQueue, ^{
        comments = [self getComments: request];
        
        [NSThread sleepForTimeInterval:1];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
            [commentsIndicator stopAnimating];
            currentStoryHeight -= 40;
            
            if (comments != nil && [comments count] > 0) {
                currentStoryHeight -= commentFormContainer.frame.size.height + 10;
                for (int i = 0; i < [comments count]; i++) {
                    Comment *comment = [comments objectAtIndex:i];
                    CGRect frame = CGRectMake(10, currentStoryHeight, 300, 300);
                    BOOL showDeleteLabel = [appDelegate currentUserId] == [comment authorId];
                    StoryCommentView *storyCommentView = [[StoryCommentView alloc] initWithFrame:frame
                        andComment:comment andIsFirst:(i == 0) andIsLast:(i == [comments count] - 1)
                        andShowDeleteLabel:showDeleteLabel andController:self];
                    storyCommentView.controller = self;
                                        
                    [scrollView addSubview: storyCommentView];
                    currentStoryHeight += storyCommentView.frame.size.height - 1; // to remove 2px border
                }
                commentFormContainer.frame = CGRectMake(commentFormContainer.frame.origin.x, currentStoryHeight + 11,
                                                        commentFormContainer.frame.size.width, commentFormContainer.frame.size.height);
                currentStoryHeight += commentFormContainer.frame.size.height + 11;
            } else {
                commentFormContainer.frame = CGRectMake(commentFormContainer.frame.origin.x, commentFormContainer.frame.origin.y - 40,
                                                        commentFormContainer.frame.size.width, commentFormContainer.frame.size.height);
            }
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];            
            [scrollView setContentSize: CGSizeMake(320, currentStoryHeight)];
            [UIView commitAnimations];
        });
    });
}

- (NSMutableArray *)getComments: request
{
    NSMutableString *path = [NSString stringWithFormat:@"/stories/%d/comments.json/", [story storyId]];
    NSDictionary *jsonData = [request send:path];
    NSMutableArray *comments;
    if(jsonData != nil){
        comments = [NSMutableArray array];
        for (NSDictionary *comment in jsonData) {
            int commentId = [(NSString *) [comment objectForKey:@"id"] intValue];
            int authorId = [(NSString *) [comment objectForKey:@"user_id"] intValue];
            int storyId = [(NSString *) [comment objectForKey:@"story_id"] intValue];       
            NSString *text = (NSString *) [comment objectForKey:@"text"];
            NSDate *updatedAt = [StoryStore parseRFC3339Date:[comment objectForKey:@"updated_at"]];
            NSDate *createdAt = [StoryStore parseRFC3339Date:[comment objectForKey:@"created_at"]];
            
            Comment *newComment = [[Comment alloc] initWithId:storyId andText:text
                                                   andAuthor:authorId andCreatedAt:createdAt
                                                    updatedAt:updatedAt andCommentId:commentId];
            [comments addObject:newComment];
        }
    }
    return comments;
}

- (void)drawAddCommentForm
{
    currentStoryHeight += 10;
    
    commentFormContainer = [[UIView alloc] initWithFrame:CGRectMake(0, currentStoryHeight, 320, 53)];
    UIColor *highColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.000];
    UIColor *lowColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.000];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    [gradient setFrame:[commentFormContainer bounds]];
    [gradient setColors:[NSArray arrayWithObjects:(id)[highColor CGColor], (id)[lowColor CGColor], nil]];
    [commentFormContainer.layer insertSublayer:gradient atIndex:0];
    commentFormContainer.layer.masksToBounds = NO;
    commentFormContainer.layer.shadowOffset = CGSizeMake(0, -1);
    commentFormContainer.layer.shadowRadius = 1;
    commentFormContainer.layer.shadowOpacity = 0.25;
    [scrollView addSubview:commentFormContainer];
    currentStoryHeight += 8;
    
    textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 8 , 230, 37)];
    textField.tag = 1;
    [textField setPlaceholder:NSLocalizedString(@"Add Comment", nil)];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [textField setTextColor:[UIColor blackColor]];
    textField.delegate = self;
    UIImage *fieldBGImage = [[UIImage imageNamed:@"text_field"] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
    [textField setBackground:fieldBGImage];
    [commentFormContainer addSubview:textField];
    
    UIButton *addCommentButton = [[UIButton alloc] initWithFrame:CGRectMake(250, 8, 60, 36)];
    [addCommentButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"add_button"]]];
    [commentFormContainer addSubview:addCommentButton];
    
    UITapGestureRecognizer *addCommentTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addCommentTapped:)];
    
    [addCommentButton addGestureRecognizer:addCommentTap];
    
    currentStoryHeight += 45;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{    
    [scrollView setContentSize:(CGSizeMake(320, currentStoryHeight + 165))];
    CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
    [self.scrollView setContentOffset:bottomOffset animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [scrollView setContentSize: CGSizeMake(320, currentStoryHeight)];
    [UIView commitAnimations];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *) event
{
    UITouch *touch = [[event allTouches] anyObject];
    if ([textField isFirstResponder] && (textField != touch.view))
    {      
        [textField resignFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{    
    [textField resignFirstResponder];    
    return YES;
}

- (void)addCommentTapped:(UITapGestureRecognizer *)gr
{  
    if([textField text] == nil || [[textField  text] isEqualToString:@""]){      
        [popupError setTextAndShow:NSLocalizedString(@"Please enter comment text", nil)];
        return;
    }
   
    [textField resignFirstResponder];
    
    UIActivityIndicatorView *addCommentIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    addCommentIndicator.frame = CGRectMake(10, 45, 100, 100);
    addCommentIndicator.center = CGPointMake(280, currentStoryHeight - 30);
    addCommentIndicator.hidesWhenStopped = YES;
    [scrollView addSubview: addCommentIndicator];
    [addCommentIndicator bringSubviewToFront: scrollView];
    [addCommentIndicator startAnimating];
   
    NSMutableString *path = [NSString stringWithFormat:@"/api/comments/create"];
    
    Request *request = [[Request alloc] init];
    
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
    dispatch_async(downloadQueue, ^{
        [request addStringToPostData:@"api_key" andValue:appDelegate.apiKey];
        [request addStringToPostData:@"creator_id" andValue:[NSString stringWithFormat:@"%d",[appDelegate currentUserId]]];
        [request addStringToPostData:@"comment[text]" andValue:[textField text]];
        [request addStringToPostData:@"story_id" andValue:[NSString stringWithFormat:@"%d",[story storyId]]];
        
        NSDictionary *jsonData = [request send:path];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [addCommentIndicator stopAnimating];
            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
            
            int commentId = [(NSString *) [jsonData objectForKey:@"id"] intValue];
            int authorId = [(NSString *) [jsonData objectForKey:@"user_id"] intValue];
            int storyId = [(NSString *) [jsonData objectForKey:@"story_id"] intValue];
            NSString *text = (NSString *) [jsonData objectForKey:@"text"];
            NSDate *updatedAt = [StoryStore parseRFC3339Date:[jsonData objectForKey:@"updated_at"]];
            NSDate *createdAt = [StoryStore parseRFC3339Date:[jsonData objectForKey:@"created_at"]];
            if(text != nil) {
                [textField setText:@""];
                
                // Make right rounded corners
                float lastCommentY = 0;
                if ([comments count] > 0) {
                    StoryCommentView *lastCommentView = [self getLastCommentView];
                    lastCommentY = lastCommentView.frame.origin.y + lastCommentView.frame.size.height;
                    if ([comments count] == 1) {
                        [lastCommentView setTopRoundedCorners];
                    } else {
                        [lastCommentView removeRoundedCorners];
                    }                    
                } else {
                    lastCommentY = storyLikeArea.frame.origin.y + storyLikeArea.frame.size.height + 10;
                }
                
                // Add new comment
                Comment *newComment = [[Comment alloc] initWithId:storyId andText:text
                                                        andAuthor:authorId andCreatedAt:createdAt
                                                        updatedAt:updatedAt andCommentId:commentId];
                
                CGRect frame = CGRectMake(10, lastCommentY - 1, 300, 300); // -1 is to remove 2px border  */
                BOOL showDeleteLabel = [appDelegate currentUserId] == [newComment authorId];
                StoryCommentView *storyCommentView = [[StoryCommentView alloc] initWithFrame:frame
                                                                              andComment:newComment
                                                                              andIsFirst:([comments count] == 0)
                                                                               andIsLast:(true)
                                                                      andShowDeleteLabel:showDeleteLabel
                                                                           andController:self];
                [comments addObject: newComment];
                storyCommentView.controller = self;
                                
                [scrollView addSubview:storyCommentView];
                currentStoryHeight += storyCommentView.frame.size.height;
            
                float newLastCommentY = storyCommentView.frame.origin.y + storyCommentView.frame.size.height; 
                commentFormContainer.frame = CGRectMake(commentFormContainer.frame.origin.x, newLastCommentY + 10,
                                                        commentFormContainer.frame.size.width, commentFormContainer.frame.size.height);
               
                [scrollView setContentSize: CGSizeMake(320,  currentStoryHeight)];
                CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
                [self.scrollView setContentOffset:bottomOffset animated:YES];
            }
       });
    });
}

- (void)deleteViewTapped:(UITapGestureRecognizer *)gr
{
    int commentId = gr.view.tag;
    NSLog(@"here");
    StoryCommentView *storyCommentView;
    for(int i = 0; i < [[scrollView subviews] count]; i++){
        if([[[scrollView subviews] objectAtIndex:i] isKindOfClass:[StoryCommentView class]]){
            StoryCommentView *delStoryCommentView = [[scrollView subviews] objectAtIndex:i];
            if (delStoryCommentView.tag == commentId) {
                storyCommentView = delStoryCommentView;
                break;
            }
        }
    }  
    
    delCommentIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    delCommentIndicator.frame = CGRectMake(10, 45, 100, 100);
    delCommentIndicator.center = CGPointMake(150, 20);
    delCommentIndicator.hidesWhenStopped = YES;
    [storyCommentView addSubview: delCommentIndicator];
    [delCommentIndicator bringSubviewToFront: storyCommentView];
    [delCommentIndicator startAnimating];    

    NSMutableString *path = [NSString stringWithFormat:@"/api/comments/%d/destroy",commentId];
    
    Request *request = [[Request alloc] init];
    
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
    dispatch_async(downloadQueue, ^{
        [request addStringToPostData:@"api_key" andValue:appDelegate.apiKey];
        
        NSDictionary *jsonData = [request send:path];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
            [delCommentIndicator stopAnimating];            
            
            NSString *success = (NSString *) [jsonData objectForKey:@"success"];            
            if(success != nil && [success boolValue]){
                //moving subviews on the place of delited one;
                for(int i = 0; i < [[scrollView subviews] count]; i++){                
                    if([[[scrollView subviews] objectAtIndex:i] isKindOfClass:[StoryCommentView class]]) {
                        StoryCommentView *view = [[scrollView subviews] objectAtIndex:i];
                        if (view.frame.origin.y > storyCommentView.frame.origin.y) {
                            CGRect rect = view.frame;
                            rect.origin = CGPointMake(view.frame.origin.x, view.frame.origin.y - storyCommentView.frame.size.height);
                            view.frame = rect;                            
                        }
                    }
                }
                
                float commentHeight = storyCommentView.frame.size.height;
                currentStoryHeight -= commentHeight;
                
                // remove comment
                [storyCommentView removeFromSuperview];                
                for (int i = 0; i < [comments count]; i++) {
                    Comment *comment = [comments objectAtIndex:i];
                    if ([comment commentId] == commentId) {
                        [comments removeObject:comment];
                        break;
                    }
                }
                
                // get new first and last comments
                StoryCommentView *firstCommentView = nil;
                StoryCommentView *lastCommentView = nil;
                for(int i = 0; i < [[scrollView subviews] count]; i++){
                    if([[[scrollView subviews] objectAtIndex:i] isKindOfClass:[StoryCommentView class]]) {
                        StoryCommentView *view = [[scrollView subviews] objectAtIndex:i];
                        if (firstCommentView == nil || view.frame.origin.y < firstCommentView.frame.origin.y) {
                            firstCommentView = view;
                        }
                        
                        if (lastCommentView == nil || view.frame.origin.y > lastCommentView.frame.origin.y) {
                            lastCommentView = view;
                        }
                    }
                }
                                
                // round first and last comments
                if(firstCommentView && lastCommentView && firstCommentView.tag == lastCommentView.tag) {
                    [firstCommentView setAllRoundedCorners];
                } else {
                    if (firstCommentView) {
                        [firstCommentView setTopRoundedCorners];
                    }
                    if (lastCommentView) {
                        [lastCommentView setBottomRoundedCorners];
                    }
                }
                
                commentFormContainer.frame = CGRectMake(commentFormContainer.frame.origin.x,
                                                        commentFormContainer.frame.origin.y - commentHeight,
                                                       commentFormContainer.frame.size.width, commentFormContainer.frame.size.height);
                
                [scrollView setContentSize: CGSizeMake(320, currentStoryHeight)];
            }
        });
    });
}

- (StoryCommentView *)getLastCommentView
{
    StoryCommentView *lastCommentView = nil;
    for(int i = 0; i < [[scrollView subviews] count]; i++){
        if([[[scrollView subviews] objectAtIndex:i] isKindOfClass:[StoryCommentView class]]) {
            StoryCommentView *view = [[scrollView subviews] objectAtIndex:i];
            
            if (lastCommentView == nil || view.frame.origin.y > lastCommentView.frame.origin.y) {
                lastCommentView = view;
            }
        }
    }
    return lastCommentView;
}

/*- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];    
}*/

@end
