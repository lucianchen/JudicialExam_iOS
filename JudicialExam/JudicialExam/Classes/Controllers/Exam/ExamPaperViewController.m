//
//  ExamPaperViewController.m
//  JudicialExam
//
//  Created by Chen, Liang on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ExamPaperViewController.h"
#import <QuartzCore/QuartzCore.h>

#define PAGE_CHANGING_MARGIN (10)
#define SlideTimerInternal (0.025)
#define SlideOffsetStepLength (1)
#define BookmarkImageNameReplacement @"icon_bookmark.png"
#define BookmarkImageName @"icon_bookmark_plain.png"

@interface ExamPaperViewController()

-(void) createPaperViews;
- (void)setPageLabelNum:(NSInteger)pageNum;
- (void)setCurrentPage:(NSInteger)page transition:(UIViewAnimationTransition)transition;
- (void)layoutSnapViewThread;
- (void)createGestureRecognizers:(id)target;
- (IBAction)handleSingleTap:(UIGestureRecognizer *)sender;
- (void)setupBookmarkIcons;
- (void)updateBookmarkIcons;
- (void)pageSelectionDidChange:(NSNotification*)notification;

@end

@implementation ExamPaperViewController
@synthesize paper;
@synthesize pageLabel;
@synthesize backwardButton;
@synthesize forwardButton;
@synthesize controlPanel;
@synthesize topBar;
@synthesize bottomBar;
@synthesize bookmarkItem;
@synthesize bookmarkItemPlain;
@synthesize bookmarkItemReplacement;
@synthesize gestureRecognizer;
@synthesize answerItem;

- (void)dealloc{
    [paper release];
    [pageLabel release];
    [backwardButton release];
    [forwardButton release];
    [controlPanel release];
    [topBar release];
    [bottomBar release];
    [bookmarkItem release];
    [bookmarkItemPlain release];
    [bookmarkItemReplacement release];
    [answerItem release];
    
    [snapViewController release];
    [scrollerViewController release];
    [pageSelector release];
    
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

    pageLabel.layer.cornerRadius = 10;
	//pageLabel.layer.shadowRadius = 5;
	pageLabel.layer.masksToBounds = YES;
	pageLabel.layer.shadowOffset = CGSizeMake(6, 6);
	pageLabel.layer.shadowColor = [[UIColor grayColor] CGColor];
	pageLabel.hidden = YES;
	forwardButton.hidden = YES;
	backwardButton.hidden = YES;

	self.topBar.hidden = YES;
	
	controlPanel.layer.cornerRadius = 5;
	controlPanel.layer.masksToBounds = YES;
    
    if (!pageSelector) {
        pageSelector = [[PaperPageSelector alloc] init];
        pageSelector.totalPage = [paper.questions count];
        [pageSelector addPageObserver:self selector:@selector(pageSelectionDidChange:)];
    }
	
	if (!scrollerViewController) {
        scrollerViewController = [[PaperScrollViewController alloc] init];
        scrollerViewController.pageSelector = pageSelector;
    }
    
    if (!snapViewController) {
        snapViewController = [[PageSnapViewController alloc] init];
        snapViewController.pageSelector = pageSelector;
    }

	[self.view addSubview:scrollerViewController.view];
	scrollerViewController.view.frame = self.view.bounds;
	//scrollerViewController.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [self createPaperViews];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - View setup
-(void) createPaperViews{    
	//init bookmark button items
	[self setupBookmarkIcons];
	
	[self createGestureRecognizers:scrollerViewController.view];
	
	[self.view bringSubviewToFront:pageLabel];
	[self.view bringSubviewToFront:topBar];
	[self.view bringSubviewToFront:bottomBar];
	[self.view bringSubviewToFront:controlPanel];
	
	if (![snapViewController isViewLoaded]) {
        [snapViewController loadView];
    }
	
	pageLabel.hidden = NO;
	forwardButton.hidden = NO;
	backwardButton.hidden = NO;
    
    [pageSelector initPage:1];
	
	[self layoutSnapViewThread];
}

- (void)setupBookmarkIcons{
	//load the image
	UIImage *buttonImage = [UIImage imageNamed:BookmarkImageNameReplacement];
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setImage:buttonImage forState:UIControlStateNormal];
	button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
	[button addTarget:self action:@selector(bookmarkCurrentPage) forControlEvents:UIControlEventTouchUpInside];
	
	//create a UIBarButtonItem with the button as a custom view
	UIBarButtonItem *customBarItem = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
	customBarItem.target = self;
	customBarItem.action = @selector(bookmarkCurrentPage);
	customBarItem.style = UIBarButtonItemStyleBordered;
	self.bookmarkItemReplacement = customBarItem;
	
	buttonImage = [UIImage imageNamed:BookmarkImageName];
	button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setImage:buttonImage forState:UIControlStateNormal];
	button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
	[button addTarget:self action:@selector(bookmarkCurrentPage) forControlEvents:UIControlEventTouchUpInside];
	customBarItem = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
	customBarItem.target = self;
	customBarItem.action = @selector(bookmarkCurrentPage);
	customBarItem.style = UIBarButtonItemStyleBordered;
	
	self.bookmarkItemPlain = customBarItem;
	
	//replace current bookmark item
	[self updateBookmarkIcons];
}

#pragma - mark PaperPageSelector
- (void)pageSelectionDidChange:(NSNotification*)notification{
    self.pageLabel.text = [NSString stringWithFormat:@"%d/%d", pageSelector.currentPage, pageSelector.totalPage];
    [self updateBookmarkIcons];
}

#pragma mark -  Orientation Handler
-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{	
	[scrollerViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[snapViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	if (snapViewController.view.superview) {
		[NSThread detachNewThreadSelector:@selector(layoutSnapViewThread) toTarget:self withObject:nil];
	}
	
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	[scrollerViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark - IBActions
- (IBAction)backward:(id)sender{
	if (pageSelector.currentPage <= 1) {
		return;
	}
	
    pageSelector.currentPage = pageSelector.currentPage - 1;
}

- (IBAction)forward:(id)sender{
	if (pageSelector.currentPage >= pageSelector.totalPage) {
		return;
	}
	
    pageSelector.currentPage = pageSelector.currentPage + 1;
}

#pragma mark - Bookmarking
- (IBAction)bookmarkCurrentPage{

	[self updateBookmarkIcons];
}

- (void)updateBookmarkIcons{
	UIBarButtonItem *buttonItem = self.bookmarkItemPlain;
	NSArray *bookmarks = nil;//[BookmarkRegistry bookmarksOnBook:self.docPath];
    
    NSInteger currentPage = pageSelector.currentPage;
	if (bookmarks && [bookmarks indexOfObject:[NSNumber numberWithInt:currentPage]] != NSNotFound) {
		buttonItem = self.bookmarkItemReplacement;
	}
	
	NSMutableArray *array = [NSMutableArray arrayWithArray:[self.topBar items]];
	[array replaceObjectAtIndex:[array indexOfObject:self.bookmarkItem] 
					 withObject:buttonItem];
	[self.topBar setItems:array animated:NO];
	self.bookmarkItem = buttonItem;
}

@end
