//
//  OptionEditViewController.m
//  JudicialExam
//
//  Created by Chen, Liang on 9/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OptionEditViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface OptionEditViewController()

- (void)submit;
- (void)cancel;

@end

@implementation OptionEditViewController
@synthesize delegate;
@synthesize option;
@synthesize textView;

- (void)dealloc{
    [option release];
    [textView release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStyleDone target:self action:@selector(submit)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
    
    self.textView.text = self.option.desc;
    self.textView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.textView.layer.borderWidth = 1;
    self.textView.layer.cornerRadius = 5;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Actions
- (void)submit{
    if ([self.delegate respondsToSelector:@selector(didSubmitOption:)]) {
        self.option.desc = self.textView.text;
        
        [self.delegate didSubmitOption:self.option];
    }
}

- (void)cancel{
    if ([self.delegate respondsToSelector:@selector(didCancelSubmitting:)]) {
        [self.delegate didCancelSubmitting:self.option];
    }
}

@end
