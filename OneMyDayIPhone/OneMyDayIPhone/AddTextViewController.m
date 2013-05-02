//
//  AddTextViewController.m
//  Onemyday
//
//  Created by dmitry.solomadin on 01.05.13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "AddTextViewController.h"
#import "EditorStore.h"

@interface AddTextViewController ()
{
    UITextView *textView;
}

@end

@implementation AddTextViewController
@synthesize controller;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // add navigation
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain
                                                                    target:self action:@selector(dismissSelf:)];
    UIBarButtonItem *publishButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain
                                                                     target:self action:@selector(saveText:)];
    [publishButton setTintColor:[UIColor colorWithRed:0.08 green:0.78 blue:0.08 alpha:0.5]];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = publishButton;
    
    // add textfield
    textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    [textView setFont:[UIFont systemFontOfSize:17]];
    [[self view] addSubview:textView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [textView becomeFirstResponder];
}

- (void)dismissSelf:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveText:(id)sender
{
    NSString *text = [textView text];
    NSString *key = [[EditorStore get] saveText:text];
    [[self controller] performSelector:@selector(addTextToTheView: withKey:) withObject:text withObject:key];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
