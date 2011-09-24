//
//  DataGenerationViewController.m
//  JudicialExam
//
//  Created by Chen, Liang on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataGenerationViewController.h"

@interface DataGenerationViewController()
- (void)done;
@end

@implementation DataGenerationViewController
@synthesize summaryTextView;
@synthesize progressView;
@synthesize statusView;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)done{
    if ([self.delegate respondsToSelector:@selector(dataGenerationDone)]) {
        [self.delegate dataGenerationDone];
    }
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
    
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    
    if (!dataGenerator) {
        dataGenerator = [[DataGenerator alloc] init];
    }
}

- (void)viewDidUnload
{
    [self setStatusView:nil];
    [self setProgressView:nil];
    [self setSummaryTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    dataGenerator.delegate = self;
    [dataGenerator startGeneration];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)statusDidUpdate:(float)percentage message:(NSString*)message{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = percentage;
        self.statusView.text = message;
    });
}

- (void)dataGenerationDone:(BOOL)succeeded{
    NSArray *missedList = dataGenerator.missedList;
    NSMutableString *missedListString = [NSMutableString string];
    NSInteger i = 0;
    
    for (NSString *item in missedList) {
        if (i == 0) {
            [missedListString appendFormat:@", "];
        }
        
        [missedListString appendFormat:@"%@", item];
    }
    
    NSString *summary = [NSString stringWithFormat:@"Generation finished. Finished Count:%d. Missed Count:%d.\n Missed List: %@", dataGenerator.count, [missedList count], missedListString];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.summaryTextView.text = summary;
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    });
    
//    if ([self.delegate respondsToSelector:@selector(dataGenerationDone)]) {
//        [self.delegate performSelectorOnMainThread:@selector(dataGenerationDone) withObject:nil waitUntilDone:NO];
//    }
}

- (void)dealloc {
    [statusView release];
    [progressView release];
    
    [dataGenerator release];
    
    [summaryTextView release];
    [super dealloc];
}
@end
