//
//  EditorViewController.m
//  OneMyDayIPhone
//
//  Created by dmitry.solomadin on 17.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "EditorViewController.h"
#import "EditorStore.h"
#import "GPUImage.h"
#import "EditorItemView.h"
#import "ViewWithAttributes.h"
#import "AddTextViewController.h"
#import "DLCImagePickerController.h"
#import "Request.h"
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AppDelegate.h"
#import "PopupError.h"

@interface EditorViewController ()
{
    AppDelegate *appDelegate;
    PopupError *popupError;
    UITextField *storyTitle;
    UIView *uploadProgressArea;
    UIProgressView *uploadProgressBar;
    UIView *storyTitleArea;
    
    UIScrollView *scrollView;
    NSMutableArray *editorItemViews;
    
    float totalSwipeRightTranslation;

    /* Rearrange variables */
    NSTimer *rearrangeScrollTimer;
    float rearrangeDifference;
    bool rearrangeMode;
}

- (void)exitEditingMode;

@end

@implementation EditorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    totalSwipeRightTranslation = 0;
    editorItemViews = [[NSMutableArray alloc] init];
    
    // add navigation
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain
                                                                    target:self action:@selector(dismissSelf:)];
    UIBarButtonItem *publishButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Publish", nil) style:UIBarButtonItemStylePlain
                                                                     target:self action:@selector(publishStory:)];
    [publishButton setTintColor:[UIColor colorWithRed:0.08 green:0.78 blue:0.08 alpha:0.5]];
    //[publishButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:11],
    //                                       UITextAttributeFont,nil] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = publishButton;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"furley_bg"]];
    
    // add scroll view
    scrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(0, 0, 320, self.view.bounds.size.height - 95)];
    scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cool_bg"]];
    [[self view] addSubview:scrollView];
    
    // add popup error
    popupError = [[PopupError alloc] initWithView:scrollView];
    
    // add upload progress area
    uploadProgressArea = [[UIView alloc] initWithFrame:CGRectMake(0, -40, 320, 40)];
    uploadProgressBar = [[UIProgressView alloc] initWithFrame:CGRectMake(10, 20, 300, 40)];
    [uploadProgressBar setProgressTintColor:[appDelegate onemydayColor]];
    [uploadProgressArea addSubview:uploadProgressBar];
    uploadProgressArea.hidden = YES;
    [scrollView addSubview:uploadProgressArea];
    
    // add story title
    storyTitleArea = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 320, 52)];
    
    storyTitle = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, 300, 38)];
    [storyTitle setPlaceholder:NSLocalizedString(@"Enter story title...", nil)];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    storyTitle.leftView = paddingView;
    storyTitle.leftViewMode = UITextFieldViewModeAlways;
    storyTitle.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    UIImage *fieldBGImage = [[UIImage imageNamed:@"text_field"] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
    [storyTitle setBackground:fieldBGImage];
    [storyTitle setDelegate:self];
    [storyTitle setReturnKeyType:UIReturnKeyDone];
    [storyTitle setText:[[EditorStore get] loadTitle]];
    storyTitle.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"furley_bg"]];
    [storyTitleArea addSubview:storyTitle];
    
    // lines under the title
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, self.view.bounds.size.width, 1)];
    lineView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.5];
    [storyTitleArea addSubview:lineView];
    
    UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, 1)];
    lineView2.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    [storyTitleArea addSubview:lineView2];
    
    [scrollView addSubview:storyTitleArea];
    
    // add previously saved images&texts if any
    NSMutableDictionary *keyToItem = [[EditorStore get] loadAllItems];
    for (NSString *key in keyToItem) {
        NSObject *item = [keyToItem objectForKey:key];
        if ([item isKindOfClass:[UIImage class]]) {
            [self addPhotoToTheView:(UIImage *)item withKey:key];
        } else if ([item isKindOfClass:[NSString class]]) {
            [self addTextToTheView:(NSString *)item withKey:key];
        }
    }
    
    // add bottom bar
    [self addBottomButtonWithTitle:@"Photo" frame:CGRectMake(0.1, 0.0, 108, 50) action:@selector(addPhoto:)];
    [self addBottomButtonWithTitle:@"Library" frame:CGRectMake(107.0, 0.0, 108, 50) action:@selector(addPhotoFromLib:)];
    [self addBottomButtonWithTitle:@"Text" frame:CGRectMake(214.0, 0.0, 107, 50) action:@selector(addText:)];
    
    // other
    [[self view] setBackgroundColor:[UIColor whiteColor]];
}

- (UIButton *)addBottomButtonWithTitle:(NSString *)title frame:(CGRect)frame action:(SEL)selector
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonBG = [[UIImage imageNamed:@"editorbar_button"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
    UIImage *buttonBGSelected = [[UIImage imageNamed:@"editorbar_button_highlight"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
    [button setBackgroundImage:buttonBG forState:UIControlStateNormal];
    [button setBackgroundImage:buttonBGSelected forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];

    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    
    frame.origin.y = self.view.bounds.size.height - frame.size.height;
    button.frame = frame;
    
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    return button;
}

- (void)addPhoto:(id)sender
{
    DLCImagePickerController *picker = [[DLCImagePickerController alloc] init];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)addText:(id)sender
{
    AddTextViewController *textVC = [[AddTextViewController alloc] init];
    [textVC setController:self];
    UINavigationController *textVCNav = [[UINavigationController alloc] initWithRootViewController:textVC];
    [self presentViewController:textVCNav animated:YES completion:nil];
}

- (void)editText:(id)sender
{
    EditorItemView *editorItemView = (EditorItemView *)[sender superview];
    NSString *text = nil;
    for (UIView *subview in [editorItemView subviews]) {
        if ([subview isKindOfClass:[UITextView class]]) {
            text = [(UITextView *)subview text];
        }
    }
    AddTextViewController *textVC = [[AddTextViewController alloc] init];
    [textVC setController:self];
    [textVC setTextToEdit:text];
    [textVC setTextToEditKey:editorItemView.key];
    UINavigationController *textVCNav = [[UINavigationController alloc] initWithRootViewController:textVC];
    [self presentViewController:textVCNav animated:YES completion:nil];
}

- (void)addPhotoFromLib:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [imagePicker setDelegate:self];
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#define DELETE_BUTTON_TAG 666

- (void)addPhotoToTheView:(UIImage *)photo withKey:(NSString *)key
{
    EditorItemView *itemView = [[EditorItemView alloc] initWithFrame:CGRectMake(10, [self getCurrentScrollHeight], 300, 300)
                                                             andType:photoItemType
                                                             andKey:key];
    [editorItemViews addObject:itemView];

    // add photo
    UIImageView *photoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    [photoView setImage:photo];
    [itemView addSubview:photoView];
    
    // add photo hidden button
    UIButton *imageBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    [itemView addSubview:imageBtn];
    [itemView bringSubviewToFront:imageBtn];    
    
    // create pan gesture recognizer (delete item)
    [self addRemoveGestureRecognizer:imageBtn];
    
    // create long press&tap gesture recognizers (rearrange items and exit rearrange)
    [self addLongPressGestureRecognizer:imageBtn];
    [self addTapGestureRecognizer:imageBtn];
    
    [scrollView addSubview:itemView];
    [scrollView setContentSize:(CGSizeMake(320, [self getCurrentScrollHeight]))];
}

- (void)addTextToTheView:(NSString *)text withKey:(NSString *)key
{
    EditorItemView *itemView = [[EditorItemView alloc] initWithFrame:CGRectMake(10, [self getCurrentScrollHeight], 300, 300)
                                                             andType:textItemType
                                                              andKey:key];
    [editorItemViews addObject:itemView];
    
    // add text
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    textView.layer.cornerRadius = 5.0;
    textView.clipsToBounds = NO;
    textView.layer.borderWidth = 1.0f;
    textView.layer.borderColor = [[UIColor colorWithRed:0.65 green:0.65 blue:0.65 alpha:0.5] CGColor];
    [textView setText:text];
    [textView setBackgroundColor:[UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:0.5]];
    [textView setFont:[UIFont systemFontOfSize:17]];
    [textView setEditable:NO];
    [textView sizeToFit];
    [itemView addSubview:textView];
    [itemView setFrame:CGRectMake(itemView.frame.origin.x, itemView.frame.origin.y,
                                  itemView.frame.size.width, textView.frame.size.height)];
    
    // add text hidden button
    UIButton *textBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 300, textView.frame.size.height)];
    [textBtn addTarget:self action:@selector(editText:) forControlEvents:UIControlEventTouchUpInside];
    [itemView addSubview:textBtn];
    [itemView bringSubviewToFront:textBtn];
    
    // create pan gesture recognizer (delete item)
    [self addRemoveGestureRecognizer:textBtn];
    
    // create long press&tap gesture recognizers (rearrange items and exit rearrange)
    [self addLongPressGestureRecognizer:textBtn];
    [self addTapGestureRecognizer:textBtn];
    
    [scrollView addSubview:itemView];
    [scrollView setContentSize:(CGSizeMake(320, [self getCurrentScrollHeight]))];
}

- (void)editTextOnTheView:(NSString *)text withKey:(NSString *)key
{
    for (EditorItemView *itemView in editorItemViews) {
        if (itemView.key == key) {
            for (UIView *subview in [itemView subviews]) {
                if ([subview isKindOfClass:[UITextView class]]) {
                    [(UITextView *)subview setText:text];
                }
            }
            break;
        }
    }
}

- (void)addRemoveGestureRecognizer:(UIView *)view
{
    UIPanGestureRecognizer *moveRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [moveRecognizer setDelegate:self];
    [view addGestureRecognizer:moveRecognizer];
}

- (void)addLongPressGestureRecognizer:(UIView *)view
{
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(rearrange:)];
    [longPressRecognizer setDelegate:self];
    [view addGestureRecognizer:longPressRecognizer];
}

- (void)addTapGestureRecognizer:(UIView *)view
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(exitRearrange:)];
    [tapGestureRecognizer setDelegate:self];
    [view addGestureRecognizer:tapGestureRecognizer];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

/* REMOVE ITEMS */

- (void)move:(UIPanGestureRecognizer *)gr
{
    EditorItemView *itemView = (EditorItemView *)[[gr view] superview];
    if (rearrangeMode) {
        [self moveToRearrange:gr itemView:itemView];
    } else {
        [self moveToDelete:gr itemView:itemView];
    }
}

- (void)moveToDelete:(UIPanGestureRecognizer *)gr itemView:(EditorItemView *)itemView
{
    float origin_position = 10;
    if ([gr state] == UIGestureRecognizerStateChanged) {
        if (itemView.frame.origin.x > 180) {
            // remove item
            [[gr view] removeGestureRecognizer:gr];
            [self deleteItemAnimation:itemView];
        } else {
            CGPoint translation = [gr translationInView:[self view]];
            
            if (translation.x > 0) {
                totalSwipeRightTranslation += translation.x;
                if (totalSwipeRightTranslation > 20) {
                    itemView.frame = CGRectOffset(itemView.frame, translation.x, 0);
                    itemView.layer.opacity = 1 - (itemView.frame.origin.x - origin_position) / 250;
                }
            }
        }
        
        [[self view] setNeedsDisplay];
        
        [gr setTranslation:CGPointZero inView:[self view]];
    } else if ([gr state] == UIGestureRecognizerStateEnded) {
        [UIView beginAnimations:@"animateReturnItemOnInitialPosition" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.3f];
        
        itemView.frame = CGRectMake(origin_position, itemView.frame.origin.y,
                                    itemView.frame.size.width, itemView.frame.size.height);
        itemView.layer.opacity = 1;
        
        [UIView commitAnimations];
        totalSwipeRightTranslation = 0;
    }
}

/* REARRANGE ITEMS */

- (void)moveToRearrange:(UIPanGestureRecognizer *)gr itemView:(EditorItemView *)itemView
{
    if ([gr state] == UIGestureRecognizerStateBegan) {
        [self stopRearrangeAnimation:itemView];
        scrollView.scrollEnabled = NO;
        itemView.layer.opacity = 0.5;
        [scrollView bringSubviewToFront:itemView];
    } else if ([gr state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gr translationInView:[self view]];
        itemView.frame = CGRectOffset(itemView.frame, 0, translation.y);

        float topThreshold = [scrollView contentOffset].y + 60;
        float bottomThreshold = [scrollView contentOffset].y + scrollView.frame.size.height - 60;
        
        float tapPosY = [gr locationInView:[self view]].y + [scrollView contentOffset].y;
        if (tapPosY < topThreshold || bottomThreshold < tapPosY) {
            rearrangeDifference = 0;
            if (tapPosY < topThreshold) {
                rearrangeDifference = tapPosY - topThreshold;
            } else if (bottomThreshold < tapPosY) {
                rearrangeDifference = tapPosY - bottomThreshold;
            }
            
            if (rearrangeScrollTimer == nil) {
                rearrangeScrollTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(rearrangeScrollToEdge:)
                                                                      userInfo:itemView repeats:YES];
            }
        } else {
            // Out of threshold area and the timer is up — bring the timer down
            if (rearrangeScrollTimer != nil) {
                [rearrangeScrollTimer invalidate];
                rearrangeScrollTimer = nil;
            }
        }
        
        [self rearrangeItem:itemView userTapPositionY:tapPosY];
    
        [[self view] setNeedsDisplay];
        [gr setTranslation:CGPointZero inView:[self view]];
    } else if ([gr state] == UIGestureRecognizerStateEnded) {
        [self exitRearrange:nil];
        scrollView.scrollEnabled = YES;
        
        [rearrangeScrollTimer invalidate];
        rearrangeScrollTimer = nil;
        
        [UIView beginAnimations:@"finishRepositionAnimation" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.3f];

        itemView.frame = CGRectMake(itemView.frame.origin.x, itemView.originY,
                                    itemView.frame.size.width, itemView.frame.size.height);
        itemView.layer.opacity = 1;
        
        [UIView commitAnimations];        
    }
}

- (void)rearrangeScrollToEdge:(NSTimer *)timer
{
    UIView *itemView = [timer userInfo];
    
    float amountToAdd = (rearrangeDifference / 10);
    float resultingOffsetY = [scrollView contentOffset].y + amountToAdd;
    
    if (resultingOffsetY < 0 || resultingOffsetY > [scrollView contentSize].height - scrollView.frame.size.height + 50) {
        return;
    }
    
    CGPoint pt = CGPointMake(0, resultingOffsetY);
    [scrollView setContentOffset:pt animated:NO];

    itemView.frame = CGRectOffset(itemView.frame, 0, amountToAdd);
}

- (void)rearrangeItem:(EditorItemView *)itemView userTapPositionY:(float)posY
{
    // Get position
    int pos = -1;
    for (EditorItemView *view in editorItemViews) {
        if (view == itemView) {
            continue;
        }
        
        float itemCenterY = view.frame.origin.y + (view.frame.size.height / 2);

        if ((posY - itemCenterY) < 0) {
            pos = [editorItemViews indexOfObject:view] > 0 ? [editorItemViews indexOfObject:view] - 1 : 0;
            break;
        }
    }
    
    if (pos == -1) {
        pos = [editorItemViews count] - 1;
    }
    
    int currentPos = [editorItemViews indexOfObject:itemView];
    
    // Change position
    if (currentPos != pos) {
        float itemSize = itemView.frame.size.height + 10;
        
        [UIView beginAnimations:@"shiftItemsAnimation" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.3f];
        
        for (int i = 0; i < [editorItemViews count]; i++) {
            EditorItemView *shiftingItemView = [editorItemViews objectAtIndex:i];
            if (pos > currentPos && i > currentPos && i <= pos) {
                shiftingItemView.frame = CGRectOffset(shiftingItemView.frame, 0, -itemSize);
            } else if (pos < currentPos && i < currentPos && i >= pos) {
                shiftingItemView.frame = CGRectOffset(shiftingItemView.frame, 0, itemSize);
            }
        }
        
        [UIView commitAnimations];
        
        [editorItemViews removeObject:itemView];
        [editorItemViews insertObject:itemView atIndex:pos];
        
        itemView.originY = [self getCurrentScrollHeightTillItemWithIndex:pos];
        
        [[EditorStore get] changeKeyPositionOldPosition:currentPos newPosition:pos];
    }
}

- (void)rearrange:(UIPanGestureRecognizer *)gr
{
    if (rearrangeMode == true) {
        return;
    }
    
    rearrangeMode = true;
    
    EditorItemView *itemView = (EditorItemView *)[[gr view] superview];
    [self startRearrangeAnimation:itemView];
}

- (void)exitRearrange:(UITapGestureRecognizer *)gr
{
    if (rearrangeMode == false) {
        return;
    }
    
    rearrangeMode = false;
    
    for (EditorItemView *view in editorItemViews) {
        [self stopRearrangeAnimation:view];
    }
}

- (void)startRearrangeAnimation:(UIView *)itemView
{
    // for antialiased transformations
    itemView.layer.borderWidth = 3;
    itemView.layer.borderColor = [UIColor clearColor].CGColor;
    itemView.layer.shouldRasterize = YES;
    
    [UIView animateWithDuration:0.15 delay:0.0
                        options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction |
                                 UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse)
                     animations:^{
                         CGAffineTransform transform = CGAffineTransformMakeRotation(0.02);
                         itemView.transform = transform;
                         
                         transform = CGAffineTransformMakeRotation(-0.02);
                         itemView.transform = transform;
                     }
                     completion:nil
     ];
}

- (void)stopRearrangeAnimation:(UIView *)view
{
    // for antialiased transformations
    view.layer.borderWidth = 0;
    view.layer.borderColor = [UIColor clearColor].CGColor;
    view.layer.shouldRasterize = NO;
    
    [view.layer removeAllAnimations];
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(0);
    view.transform = transform;
}

/* DELETE ITEMS */

- (void)deleteItemAnimation:(EditorItemView *)itemView
{
    [UIView animateWithDuration:0.5f
                     animations:^{
                         itemView.frame = CGRectMake(320, itemView.frame.origin.y,
                                                     itemView.frame.size.width, itemView.frame.size.height);
                         itemView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self deleteItem:itemView];
                     }];
}

- (void)deleteItem:(EditorItemView *)itemView
{
    NSString *itemKey = [itemView key];
    [itemView removeFromSuperview];
    if ([itemView type] == photoItemType) {
        [[EditorStore get] deleteImageWithKey:itemKey];
    } else if ([itemView type] == textItemType) {
        [[EditorStore get] deleteTextWithKey:itemKey];
    }
    
    for (EditorItemView *view in editorItemViews) {
        if (view.frame.origin.y > itemView.frame.origin.y) {
            [UIView beginAnimations:@"searchGrowUp" context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            [UIView setAnimationDuration:0.3f];
            
            view.frame = CGRectOffset(view.frame, 0, -(itemView.frame.size.height + 10));
            
            [UIView commitAnimations];
        }
    }
}

/* PUBLISH STORY */

- (void)publishStory:(id)sender
{
    if ([[storyTitle text] length] == 0) {
        [popupError setTextAndShow:NSLocalizedString(@"Please, enter story title.", nil)];
        return;
    }
    
    BOOL hasImage = false;
    for (EditorItemView *itemView in editorItemViews) {
        if ([itemView type] == photoItemType) {
            hasImage = true;
        }
    }
    
    if (!hasImage) {
        [popupError setTextAndShow:NSLocalizedString(@"Your story should have at least one image.", nil)];
        return;
    }
    
    Request *request = [[Request alloc] init];

    [request addStringToPostData:@"api_key" andValue: appDelegate.apiKey];
    [request addStringToPostData:@"author_id" andValue: [NSString stringWithFormat:@"%d", appDelegate.currentUserId]];
    [request addStringToPostData:@"story[title]" andValue:[storyTitle text]];
    
    for (int i=0; i < [editorItemViews count]; i++) {
        EditorItemView *itemView = [editorItemViews objectAtIndex:i];
        NSString *elementOrder = [NSString stringWithFormat:@"%d", i];
        if ([itemView type] == photoItemType) {
            UIImage *image = [[EditorStore get] getImageWithKey:[itemView key]];
            [request addImageToPostData:@"story_photos[][photo]" andValue:image];
            [request addStringToPostData:@"story_photos[][element_order]" andValue:elementOrder];
        } else if ([itemView type] == textItemType) {
            NSString *text = [[EditorStore get] getTextWithKey:[itemView key]];
            [request addStringToPostData:@"story_texts[][text]" andValue:text];
            [request addStringToPostData:@"story_texts[][element_order]" andValue:elementOrder];
        }
    }
    
    [self showProgressBar];
    [request sendAsync:@"/api/stories/create_and_publish"
            onProgress:^(float percents) {
                [uploadProgressBar setProgress:(percents / 100)];
                if (percents == 100) {
                    [self hideProgressBar];
                    [self dismissSelf:nil];
                }
            }
              onFinish:^(NSDictionary *response, int statusCode){
                  NSLog(@"here %@", [response objectForKey:@"message"]);
                  NSLog(@"here %d", statusCode);
              }];
}

- (void)showProgressBar
{
    [self shiftProgressBar:40];
    uploadProgressArea.hidden = NO;
}

- (void)hideProgressBar
{
    [self shiftProgressBar:-40];
    uploadProgressArea.hidden = YES;
}

- (void)shiftProgressBar:(int)shiftAmount
{
    [UIView beginAnimations:@"animateReturnItemOnInitialPosition" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.5f];
    
    for (EditorItemView *itemView in editorItemViews) {
        itemView.frame = CGRectMake(itemView.frame.origin.x, itemView.frame.origin.y + shiftAmount,
                                    itemView.frame.size.width, itemView.frame.size.height);
    }
    
    uploadProgressArea.frame = CGRectMake(uploadProgressArea.frame.origin.x, uploadProgressArea.frame.origin.y + shiftAmount,
                                          uploadProgressArea.frame.size.width, uploadProgressArea.frame.size.height);
    storyTitleArea.frame = CGRectMake(storyTitleArea.frame.origin.x, storyTitleArea.frame.origin.y + shiftAmount,
                                      storyTitleArea.frame.size.width, storyTitleArea.frame.size.height);
    
    [UIView commitAnimations];
}

/* MISC METHODS */

- (float)getCurrentScrollHeight
{
    return [self getCurrentScrollHeightTillItemWithIndex:-1];
}

- (float)getCurrentScrollHeightTillItemWithIndex:(int)itemIndex
{
    float height = 52;
    int count = 0;
    for (int i = 0; i < [editorItemViews count]; i++) {
        if (i < itemIndex || itemIndex == -1) {
            EditorItemView *view = [editorItemViews objectAtIndex:i];
            height += view.frame.size.height;
            count++;            
        }
    }
    return height + count * 10 + 10;
}

- (void)imagePickerControllerDidCancel:(DLCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(DLCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (info) {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageDataToSavedPhotosAlbum:[info objectForKey:@"data"] metadata:nil
                                  completionBlock:^(NSURL *assetURL, NSError *error) {
             if (error) {
                 NSLog(@"ERROR: the image failed to be written");
             } else {
                 [self findLargeImage:assetURL];
             }
         }];
    }
}

- (void)hiresImageAvailable:(UIImage *)image
{
    NSString *key = [[EditorStore get] saveImage:image];
    [self addPhotoToTheView:image withKey: key];
}

- (void)findLargeImage:(NSURL *)asseturl
{
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        ALAssetRepresentation *rep = [myasset defaultRepresentation];
        CGImageRef iref = [rep fullResolutionImage];
        if (iref) {
            UIImage *largeimage = [UIImage imageWithCGImage:iref];
            [self hiresImageAvailable:largeimage];
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror) {
        NSLog(@"booya, cant get image - %@",[myerror localizedDescription]);
    };
    
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:asseturl resultBlock:resultblock failureBlock:failureblock];
}

- (void)dismissSelf:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [[EditorStore get] saveTitle:[textField text]];
    [textField resignFirstResponder];
    return YES;
}

@end
