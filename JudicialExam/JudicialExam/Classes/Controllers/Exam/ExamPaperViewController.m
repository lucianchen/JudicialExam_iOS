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

#define TimeRefreshInterval (1)

@interface ExamPaperViewController()
@property(nonatomic, retain) NSDate *dedlineTime;

-(void) createPaperViews;
- (void)layoutSnapViewThread;
- (void)createGestureRecognizers:(id)target;
- (IBAction)handleSingleTap:(UIGestureRecognizer *)sender;
- (void)setupBookmarkIcons;
- (void)updateBookmarkIcons;
- (void)pageSelectionDidChange:(NSNotification*)notification;
- (void)updateTime:(NSTimer*)theTimer;


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
@synthesize timeItem;
@synthesize gestureRecognizer;
@synthesize answerItem;
@synthesize dedlineTime;

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
    
    [timeItem release];
    [dedlineTime release];
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

    self.navigationController.navigationBarHidden = YES;
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
        scrollerViewController.paper = self.paper;
    }
    
    if (!snapViewController) {
        snapViewController = [[PageSnapViewController alloc] init];
        snapViewController.pageSelector = pageSelector;
        
    }

	[self.view addSubview:scrollerViewController.view];
	scrollerViewController.view.frame = self.view.bounds;
    scrollerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	//scrollerViewController.delegate = self;
}

- (void)viewDidUnload
{
    [self setTimeItem:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self createPaperViews];
    [scrollerViewController viewWillAppear:animated];
    
    //Examing time: 3 hours
    self.dedlineTime = [[NSDate date] dateByAddingTimeInterval:3 * 60 * 60];
    timer = [NSTimer timerWithTimeInterval:TimeRefreshInterval target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:[[NSRunLoop currentRunLoop] currentMode]];
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
    
    [pageSelector initPage:1];
    self.pageLabel.text = [NSString stringWithFormat:@"%d/%d", pageSelector.currentPage, pageSelector.totalPage];
	
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
	
	[self layoutSnapViewThread];
}

- (void)layoutSnapViewThread{
	NSAutoreleasePool *pool =[[NSAutoreleasePool alloc] init];
	if (!snapViewController.view.superview) {
		UIView *view = snapViewController.view;
		[self.bottomBar addSubview:view];
		
		snapViewController.view.frame = CGRectMake(0, 0, self.bottomBar.frame.size.width, self.bottomBar.frame.size.height);
		snapViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	}else {
		[snapViewController.view setNeedsDisplay];
	}
	
	[pool drain];
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

#pragma mark -
#pragma mark Gesture Recognizers
- (void)createGestureRecognizers:(id)target {
	UITapGestureRecognizer *tapper  = [[UITapGestureRecognizer alloc]
									   initWithTarget:self action:@selector(handleSingleTap:)];
	tapper.numberOfTapsRequired = 2;
    //tapper.numberOfTouchesRequired = 2;
    tapper.cancelsTouchesInView = NO;
    tapper.delaysTouchesEnded = NO;
    
	[target addGestureRecognizer:tapper];
	[tapper release];
    
	gestureRecognizer = tapper;
}


- (IBAction)handleSingleTap:(UIGestureRecognizer *)sender{	
	if (self.topBar.hidden) {
		self.topBar.hidden = NO;
	}
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	
	[self.view bringSubviewToFront:self.topBar];
	[self.view bringSubviewToFront:self.bottomBar];
	[self.view bringSubviewToFront:self.controlPanel];
	if (self.topBar.frame.origin.y < 0) {
		self.topBar.alpha = 0.9;
		self.bottomBar.alpha = 0.9;
		CGRect frame = self.controlPanel.frame;
		frame.origin.x -= frame.size.width;
		self.controlPanel.frame = frame;
		frame = self.topBar.frame;
		frame.origin.y += frame.size.height;
		self.topBar.frame = frame;
		frame = self.bottomBar.frame;
		frame.origin.y -= frame.size.height;
		//frame.origin.y -= 10;
		self.bottomBar.frame = frame;
        
        frame = self.pageLabel.frame;
        frame.origin.y += 44;
        self.pageLabel.frame = frame;
	}else {
		self.topBar.alpha = 0;
		self.bottomBar.alpha = 0;
		CGRect frame = self.controlPanel.frame;
		frame.origin.x += frame.size.width;
		self.controlPanel.frame = frame;
		self.controlPanel.frame = frame;
		frame = self.topBar.frame;
		frame.origin.y -= frame.size.height;
		self.topBar.frame = frame;
		frame = self.bottomBar.frame;
		frame.origin.y += frame.size.height;
		//frame.origin.y += 10;
		self.bottomBar.frame = frame;
        
        frame = self.pageLabel.frame;
        frame.origin.y -= 44;
        self.pageLabel.frame = frame;
	}
    
	[UIView commitAnimations];
}

- (IBAction)submit:(id)sender {
    
}

- (void)updateTime:(NSTimer*)theTimer{
    NSDate *date = [NSDate date];
    NSUInteger flags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:flags fromDate:date toDate:self.dedlineTime options:0];
    NSString *titleString = [NSString stringWithFormat:@"%d:%d:%d", [components hour], [components minute], [components second]];
    self.timeItem.title = titleString;
}
@end
