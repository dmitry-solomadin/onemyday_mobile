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
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface EditorViewController ()
{
    UIScrollView *scrollView;
    float totalSwipeRightTranslation;
}

- (void)exitEditingMode;

@end

@implementation EditorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    totalSwipeRightTranslation = 0;
    
    // add navigation
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain
                                                                    target:self action:@selector(dismissSelf:)];
    UIBarButtonItem *publishButton = [[UIBarButtonItem alloc] initWithTitle:@"Publish" style:UIBarButtonItemStylePlain
                                                                     target:self action:@selector(publishStory:)];
    [publishButton setTintColor:[UIColor colorWithRed:0.08 green:0.78 blue:0.08 alpha:0.5]];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = publishButton;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"furley_bg"]];
    
    // add scroll view
    scrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(0, 0, 320, self.view.bounds.size.height - 95)];
    scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cool_bg"]];
    [[self view] addSubview:scrollView];
    
    // add story title
    UITextField *storyTitle = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 300, 38)];
    [storyTitle setPlaceholder:@"Enter story title..."];
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
    [scrollView addSubview:storyTitle];
    
    // lines under the title
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 53, self.view.bounds.size.width, 1)];
    lineView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.5];
    [scrollView addSubview:lineView];
    
    UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 54, self.view.bounds.size.width, 1)];
    lineView2.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    [scrollView addSubview:lineView2];
    
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
    
    [scrollView addSubview:itemView];
    [scrollView setContentSize:(CGSizeMake(320, [self getCurrentScrollHeight]))];
}

- (void)addTextToTheView:(NSString *)text withKey:(NSString *)key
{
    EditorItemView *itemView = [[EditorItemView alloc] initWithFrame:CGRectMake(10, [self getCurrentScrollHeight], 300, 300)
                                                             andType:textItemType
                                                              andKey:key];
    
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
    
    [scrollView addSubview:itemView];
    [scrollView setContentSize:(CGSizeMake(320, [self getCurrentScrollHeight]))];
}

- (void)addRemoveGestureRecognizer:(UIView *)view
{
    UIPanGestureRecognizer *moveRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [moveRecognizer setDelegate:self];
    [view addGestureRecognizer:moveRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)move:(UIPanGestureRecognizer *)gr
{
    EditorItemView *itemView = (EditorItemView *)[[gr view] superview];
    float origin_position = 10;
    if ([gr state] == UIGestureRecognizerStateChanged) {        
        if (itemView.frame.origin.x > 180) {
            // remove item
            [[gr view] removeGestureRecognizer:gr];
            [self deleteItemAnimation:itemView];
        } else {
            CGPoint translation = [gr translationInView:[self view]];
            
            if (translation.x > 0) {
                totalSwipeRightTranslation+= translation.x;
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

- (void)editTextOnTheView:(NSString *)text withKey:(NSString *)key
{
    for (UIView *view in [scrollView subviews]) {        
        if ([view isKindOfClass:[EditorItemView class]]) {
            EditorItemView *itemView = (EditorItemView *)view;
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
}

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
    
    for (UIView *view in [scrollView subviews]) {
        if ([view isKindOfClass:[EditorItemView class]] &&
            view.frame.origin.y > itemView.frame.origin.y) {
            [UIView beginAnimations:@"searchGrowUp" context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            [UIView setAnimationDuration:0.3f];
            
            view.frame = CGRectOffset(view.frame, 0, -(itemView.frame.size.height + 10));
            
            [UIView commitAnimations];
        }
    }
}

- (float)getCurrentScrollHeight
{
    float height = 52;
    int count = 0;
    for (UIView *view in [scrollView subviews]) {
        if ([view isKindOfClass:[EditorItemView class]]) {
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
