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

@interface ShowStoryViewController ()

@end

@implementation ShowStoryViewController
@synthesize story, scrollView;

UIButton *likeButtonView;
UILabel *numberOfPeopleView;
UILabel *numberOfPeopleTextView;
UIActivityIndicatorView *likeIndicator;
UIActivityIndicatorView *commentsIndicator;
UITextView *likeView;
AppDelegate *appDelegate;
CGFloat currentStoryHeight;

- (id) initWithStory:(Story *)_story
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
            }
        }
        
        likeView = [[UITextView alloc] init];
        
        likeView.clipsToBounds = YES;
        likeView.layer.cornerRadius = 10.0;
        likeView.layer.borderColor = [[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1] CGColor];
        likeView.layer.borderWidth = 1;
        [likeView setEditable:NO];
        [likeView setFont:[UIFont systemFontOfSize:15]];
        [likeView setBackgroundColor:[UIColor whiteColor]];
        [likeView setContentInset:UIEdgeInsetsMake(0, -8, 0, 0)];
        [scrollView addSubview:likeView];
        likeView.frame = CGRectMake(10, currentStoryHeight, 300, 55);
        
        currentStoryHeight += 60;
        
        likeButtonView = [[UIButton alloc] init];
        likeButtonView.clipsToBounds = YES;
        likeButtonView.layer.cornerRadius = 4.0;
        likeButtonView.layer.borderColor = [[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1] CGColor];
        likeButtonView.layer.borderWidth = 1;

        if (![story isLikedByUser]) {
            [likeButtonView setTitle:@"Like" forState:UIControlStateNormal];
        } else {
            [likeButtonView setTitle:@"Liked" forState:UIControlStateNormal];
        }
        
        [likeButtonView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [likeButtonView setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1]];     
        [likeView addSubview:likeButtonView];
        likeButtonView.frame = CGRectMake(15, 10, 70, 35);
        
        UITapGestureRecognizer *likeButtonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeButtonTapped:)];
        [likeButtonView addGestureRecognizer:likeButtonTap];
        
        numberOfPeopleView = [[UILabel alloc] init];
        numberOfPeopleView.text = [NSString stringWithFormat:@"%d", [story likesCount]];
        [numberOfPeopleView setFont:[UIFont systemFontOfSize:14]];
        [likeView addSubview:numberOfPeopleView];
        numberOfPeopleView.frame = CGRectMake(93, 10, 20, 35);
        
        numberOfPeopleTextView = [[UILabel alloc] init];
        numberOfPeopleTextView.text = @"people likes this story";
        [numberOfPeopleTextView setFont:[UIFont systemFontOfSize:14]];
        [likeView addSubview:numberOfPeopleTextView];
        numberOfPeopleTextView.frame = CGRectMake(105, 10, 200, 35);
        [self placeLikeTextCorrectly:[story likesCount]];
        
        [scrollView setContentSize:(CGSizeMake(10, currentStoryHeight))];
        [scrollView setAutoresizesSubviews:NO];
        
        [self getStoryComments];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)placeLikeTextCorrectly:(int)likesCount
{
    if (likesCount > 9) {
        numberOfPeopleTextView.frame = CGRectMake(112, numberOfPeopleTextView.frame.origin.y,
                                                  numberOfPeopleTextView.frame.size.width, numberOfPeopleTextView.frame.size.height);
    } else {
        numberOfPeopleTextView.frame = CGRectMake(105, numberOfPeopleTextView.frame.origin.y,
                                                  numberOfPeopleTextView.frame.size.width, numberOfPeopleTextView.frame.size.height);
    }
    
    if (likesCount == 0) {
        numberOfPeopleTextView.hidden = true;
        numberOfPeopleView.hidden = true;
    } else {
        numberOfPeopleTextView.hidden = false;
        numberOfPeopleView.hidden = false;
    }
}

- (void)likeButtonTapped:(UITapGestureRecognizer *)gr 
{
    likeIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    likeIndicator.frame = CGRectMake(10, 45, 100, 100);
    likeIndicator.center = CGPointMake(110, 25);
    likeIndicator.hidesWhenStopped = YES;
    [likeView addSubview: likeIndicator];
    [likeIndicator bringSubviewToFront: likeView];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [likeIndicator startAnimating];    
    
    NSString *likeOrUnlike;
    if([story isLikedByUser])likeOrUnlike = @"unlike";
    else likeOrUnlike = @"like";
    NSMutableString *path = [NSString stringWithFormat:@"/api/stories/%d/%@", [story storyId], likeOrUnlike];
    NSString *postData =[[NSString alloc] initWithFormat:
                         @"api_key=%@&user_id=%@",appDelegate.apiKey, appDelegate.currentUserId];
    
    Request *request = [[Request alloc] init];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
    dispatch_async(downloadQueue, ^{
        // do our long running process here      
        
        NSDictionary *jsonData = [request getDataFrom: path requestData: postData];
        [NSThread sleepForTimeInterval:3];
        // do any UI stuff on the main UI thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [likeIndicator stopAnimating];
            if([request errorMsg] != nil){
                [appDelegate alertStatus:@"" :[request errorMsg]];
                return;
            } else {
                int success = [(NSString *) [jsonData objectForKey:@"success"] intValue];
                if(success == 1){
                    if(![story isLikedByUser]){
                        [likeButtonView setTitle:@"Liked" forState:UIControlStateNormal];
                        [story setLikesCount: [story likesCount] + 1];
                        [story setIsLikedByUser: true];
                    } else {
                        [likeButtonView setTitle:@"Like" forState:UIControlStateNormal];
                        [story setLikesCount: [story likesCount] - 1];
                        [story setIsLikedByUser: false];
                    }
                    [self placeLikeTextCorrectly:[story likesCount]];
                    [self saveLikeToCache];
                    numberOfPeopleView.text = [NSString stringWithFormat:@"%d",[story likesCount]];
                }        
            }      
        });
    });    
}

- (void)saveLikeToCache
{
    NSMutableArray *cachedStories = [[StoryStore get] getCachedStories];
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

- (void)getStoryComments
{
    commentsIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    commentsIndicator.frame = CGRectMake(10, 45, 100, 100);
    commentsIndicator.center = CGPointMake(160, currentStoryHeight + 20);
    commentsIndicator.hidesWhenStopped = YES;
    [scrollView addSubview: commentsIndicator];
    [commentsIndicator bringSubviewToFront: scrollView];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [scrollView setContentSize: CGSizeMake(320, currentStoryHeight + 50)];
    [commentsIndicator startAnimating];
    
    Request *request = [[Request alloc] init];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
    dispatch_async(downloadQueue, ^{
        // do our long running process here        
        NSArray *comments = [self getComments: request];
        [NSThread sleepForTimeInterval:3];
        // do any UI stuff on the main UI thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [commentsIndicator stopAnimating];         
            //if([request errorMsg] != nil){
            //    [appDelegate alertStatus:@"" :[request errorMsg]];
                //return;
            //} else if(comments != nil && [comments count] > 0){
                currentStoryHeight += 5;
                for (int i = 0; i < [comments count]; i++) {
                    Comment *comment = [comments objectAtIndex:i];
                    CGRect frame = CGRectMake(10, currentStoryHeight, 300, 300);
                    StoryCommentView *storyCommentView = [[StoryCommentView alloc] initWithFrame:frame
                                                                                      andComment:comment
                                                                                      andIsFirst:(i == 0)
                                                                                       andIsLast:(i == [comments count] - 1)];
                    storyCommentView.controller = self;
                    [scrollView addSubview: storyCommentView];
                    currentStoryHeight += storyCommentView.frame.size.height - 1; // to remove 2px border
                }
                currentStoryHeight += 15;
            //}
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            [scrollView setContentSize: CGSizeMake(320,  currentStoryHeight)];
            [UIView commitAnimations];
        });
    });
}

- (NSMutableArray *)getComments: request
{
    NSMutableString *path = [NSString stringWithFormat:@"/stories/%d/comments.json/", [story storyId]];  
    NSDictionary *jsonData = [request getDataFrom: path requestData:nil];
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

- (NSMutableArray *)getComments1: request
{
    NSMutableArray *comments = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        Comment *newComment = [[Comment alloc] initWithId:1 andText:@"test"
                                                andAuthor:1 andCreatedAt:[NSDate date]
                                                updatedAt:[NSDate date] andCommentId:1];
        [comments addObject:newComment];
    }

    return comments;
}


@end
