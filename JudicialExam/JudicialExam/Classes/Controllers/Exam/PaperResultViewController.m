//
//  PaperResultViewController.m
//  JudicialExam
//
//  Created by Chen, Liang on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PaperResultViewController.h"

@interface PaperResultViewController()
- (void)returnToParent;
@end

@implementation PaperResultViewController
@synthesize resultView;
@synthesize summaryContainer;
@synthesize scoreLabel;
@synthesize ratioLabel;
@synthesize fullMarkLabel;
@synthesize resultInfo;
@synthesize delegate;

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
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                              target:self 
                                              action:@selector(returnToParent)] autorelease];
    
    if (!summaryViewController) {
        summaryViewController = [[ExamSummaryViewController alloc] init];
    }
    
    if (!summaryViewController.view.superview) {
        [self.summaryContainer addSubview:summaryViewController.view];
        summaryViewController.view.frame = self.summaryContainer.bounds;
        summaryViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.resultInfo) {
        self.scoreLabel.text = [NSString stringWithFormat:@"%d", self.resultInfo.score];
        self.ratioLabel.text = [NSString stringWithFormat:@"%.1f%%", self.resultInfo.ratio * 100];
        
        Paper *paper = self.resultInfo.paper;
        NSArray *wrongAnswers = self.resultInfo.wrongAnswers;
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSMutableArray array], [NSMutableArray array], [NSMutableArray array], nil] 
                                                                       forKeys:[NSArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:1], [NSNumber numberWithInt:2], nil]];
        
        for (NSInteger i = 1; i <= 100; ++i) {
            BOOL shouldHighlight = [wrongAnswers containsObject:[NSNumber numberWithInt:i]];
            
            if (shouldHighlight) {
                NSInteger section = 0;
                NSInteger page = i;
                NSInteger firstSectionNum = ([paper.distributionType intValue] == ValueDistributionTypeOne) ? 30 : 50;
                
                if (page > firstSectionNum && page <= 80) {
                    section = 1;
                }else if (page > 80) {
                    section = 2;
                }
                
                NSMutableArray *sectionArray = [dict objectForKey:[NSNumber numberWithInt:section]];
                [sectionArray addObject:[NSNumber numberWithInt:page]];
            }
        }
        
        ExamSummaryViewController *controller = summaryViewController;
        controller.style = ([paper.distributionType intValue] == ValueDistributionTypeOne) ? SummaryStyleOne : SummaryStyleTwo;
        
        controller.historyMode = YES;
        controller.highlightDict = dict;
        controller.delegate = (NSObject<ExamSummaryDelegate>*)(self.delegate);
        
        [controller viewWillAppear:animated];
        [controller.summaryTableView reloadData];
    }
}

- (void)viewDidUnload
{
    [self setSummaryContainer:nil];
    [self setScoreLabel:nil];
    [self setRatioLabel:nil];
    [self setFullMarkLabel:nil];
    [self setResultView:nil];
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
    if ([self.delegate respondsToSelector:@selector(dismissSummaryInfo)]) {
        [self.delegate dismissSummaryInfo];
    }
}

- (void)dealloc {
    [summaryContainer release];
    [scoreLabel release];
    [ratioLabel release];
    [fullMarkLabel release];
    [resultView release];
    
    [resultInfo release];
    
    [summaryViewController release];
    
    [super dealloc];
}
@end
