//
//  AnalysisViewController.m
//  JudicialExam
//
//  Created by Chen, Liang on 9/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnalysisViewController.h"

@interface AnalysisViewController()

- (void)returnToParent;
@end

@implementation AnalysisViewController
@synthesize question;
@synthesize analysisView;
@synthesize delegate;

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
    
    if (question) {
        self.analysisView.text = question.analysis;
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(returnToParent)];
}

- (void)viewDidUnload
{
    [self setAnalysisView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)returnToParent{
    if ([self.delegate respondsToSelector:@selector(dismissAnalysis)]) {
        [self.delegate dismissAnalysis];
    }
}

- (void)dealloc {
    [analysisView release];
    [super dealloc];
}
@end
