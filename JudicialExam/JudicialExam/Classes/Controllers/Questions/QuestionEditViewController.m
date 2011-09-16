//
//  QuestionEditViewController.m
//  JudicialExam
//
//  Created by Chen Liang on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QuestionEditViewController.h"

@interface QuestionEditViewController()

- (void)submit;
- (void)cancel;

@end

@implementation QuestionEditViewController
@synthesize delegate;
@synthesize question;
@synthesize titleView;
@synthesize optionsTableView;
@synthesize descView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [question release];
    
    [titleView release];
    [optionsTableView release];
    [descView release];
    [super dealloc];
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
    
    self.titleView.text = self.question.title;
    self.descView.text = self.question.analysis;
}

- (void)viewDidUnload
{
    [self setTitleView:nil];
    [self setOptionsTableView:nil];
    [self setDescView:nil];
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
    if ([self.delegate respondsToSelector:@selector(didSubmitQuestion:)]) {
        self.question.title = self.titleView.text;
        self.question.analysis = self.descView.text;
        
        [self.delegate didSubmitQuestion:self.question];
    }
}

- (void)cancel{
    if ([self.delegate respondsToSelector:@selector(didCancelSubmitting)]) {
        [self.delegate didCancelSubmitting];
    }
}

@end
