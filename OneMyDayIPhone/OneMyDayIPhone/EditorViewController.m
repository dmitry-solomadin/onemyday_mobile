//
//  EditorViewController.m
//  OneMyDayIPhone
//
//  Created by dmitry.solomadin on 17.04.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "EditorViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface EditorViewController ()

@end

@implementation EditorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // add navigation
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain
                                                                        target:self action:@selector(dismissSelf:)];
        UIBarButtonItem *publishButton = [[UIBarButtonItem alloc] initWithTitle:@"Publish" style:UIBarButtonItemStylePlain
                                                                        target:self action:@selector(publishStory:)];
        [publishButton setTintColor:[UIColor colorWithRed:0.08 green:0.78 blue:0.08 alpha:0.5]];
        self.navigationItem.leftBarButtonItem = cancelButton;
        self.navigationItem.rightBarButtonItem = publishButton;
        
        // add bottom bar
        [self addBottomButtonWithTitle:@"Photo" frame:CGRectMake(0.1, 0.0, 108, 50) action:@selector(addPhoto:)];
        [self addBottomButtonWithTitle:@"Library" frame:CGRectMake(107.0, 0.0, 108, 50) action:@selector(addPhotoFromLib:)];
        [self addBottomButtonWithTitle:@"Text" frame:CGRectMake(214.0, 0.0, 107, 50) action:nil];
        
        // other
        [[self view] setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (UIButton *)addBottomButtonWithTitle:(NSString *)title frame:(CGRect)frame action:(SEL)selector {
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
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    [imagePicker setDelegate:self];
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)addPhotoFromLib:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [imagePicker setDelegate:self];
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"okay we've got the image.");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissSelf:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
