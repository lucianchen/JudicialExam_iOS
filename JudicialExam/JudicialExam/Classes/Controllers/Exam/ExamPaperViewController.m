//
//  ExamPaperViewController.m
//  JudicialExam
//
//  Created by Chen, Liang on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ExamPaperViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ExamSummaryViewController.h"
#import "Util.h"
#import "Constants.h"
#import "Answer.h"
#import "Question.h"
#import "PaperJudge.h"
#import "PaperResult.h"
#import "PaperResultViewController.h"
#import "AnalysisViewController.h"
#import "Bookmark.h"

#define PAGE_CHANGING_MARGIN (10)
#define SlideTimerInternal (0.025)
#define SlideOffsetStepLength (1)
#define BookmarkImageNameReplacement @"icon_bookmark.png"
#define BookmarkImageName @"icon_bookmark_plain.png"

#define TimeRefreshInterval (1)

#define AlertViewTitleReturn @"退出测验"
#define AlertViewTitleSubmit @"确认交卷"

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
- (void)recordAnswers;
- (void)judgeAnswers;
- (void)showAnalysis;
- (Bookmark*)bookmarkOfPage:(NSInteger)page;

@end

@implementation ExamPaperViewController
@synthesize submitItem;
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
@synthesize record;

- (void)dealloc{    
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
    [submitItem release];
    
    [paper release];
    [record release];
    
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
}

- (void)viewDidUnload
{
    [self setTimeItem:nil];
    [self setSubmitItem:nil];
    [super viewDidUnload];
    
    initialized = NO;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (!initialized) {
        [self createPaperViews];
        
        NSDate *destDate = nil;
        if (!record) {
            self.record = (Record*)[NSEntityDescription insertNewObjectForEntityForName:EntityNameRecord inManagedObjectContext:[Util managedObjectContext]];
            record.date = [NSDate date];
            
            if (record) {
                record.paper = self.paper;
            }
            
            //Examing time: 3 hours
            destDate = [[NSDate date] dateByAddingTimeInterval:3 * 60 * 60];
        }else if (![record.completed boolValue]) {
            //config the context
            destDate = [[NSDate date] dateByAddingTimeInterval:[record.leftTime doubleValue]];
            NSInteger lastPageNum = [record.lastPage intValue];
            pageSelector.currentPage = lastPageNum;
            
            if (!scrollerViewController.optionDict) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                NSArray *answers = [record.answers allObjects];
                for (Answer *answer in answers) {
                    NSMutableArray *indexArray = [NSMutableArray array];
                    for (Option *option in [answer.options allObjects]) {
                        NSArray *options = [answer.question.options allObjects];
                        NSInteger index = [options indexOfObject:option];
                        
                        [indexArray addObject:[NSNumber numberWithInt:index]];
                    }
                    
                    [dict setObject:indexArray forKey:answer.Id];
                }
                
                scrollerViewController.optionDict = dict;
            }
        }
        
        scrollerViewController.record = record;
        [scrollerViewController viewWillAppear:animated];
        
        if (![record.completed boolValue]) {
            self.dedlineTime = destDate;
            timer = [NSTimer timerWithTimeInterval:TimeRefreshInterval target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:[[NSRunLoop currentRunLoop] currentMode]];
        }else {
            self.submitItem.title = @"查看答卷";
            self.submitItem.action = @selector(judgeAnswers);
            
            self.timeItem.title = @"详细解析";
            self.timeItem.action = @selector(showAnalysis);
        }
        
        initialized = YES;
    }
    
    [self setupBookmarkIcons];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [scrollerViewController viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - View setup
-(void) createPaperViews{    
	//init bookmark button items
    
    if (pageSelector.currentPage < 1) {
        [pageSelector initPage:1];
    }
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
    Bookmark *bookmark = [self bookmarkOfPage:pageSelector.currentPage];
    
    if (bookmark) {
        //remove bookark
        [[Util managedObjectContext] deleteObject:bookmark];
    }else {
        bookmark = [NSEntityDescription insertNewObjectForEntityForName:EntityNameBookmark inManagedObjectContext:[Util managedObjectContext]];
        
        Question *question = [scrollerViewController questionByPage:pageSelector.currentPage];
        bookmark.itemType = [NSNumber numberWithInt:BookmarkTypeQuestion];
        bookmark.itemId = question.Id;
    }
    
	[self updateBookmarkIcons];
}

- (void)updateBookmarkIcons{
	UIBarButtonItem *buttonItem = self.bookmarkItemPlain;
    
    Bookmark *bookmark = [self bookmarkOfPage:pageSelector.currentPage];
    if (bookmark) {
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
    NSDictionary *optionDict = scrollerViewController.optionDict;
    BOOL valid = NO;
    
    if ([optionDict count] == 100) {
        NSInteger count = 0;
        
        for (NSArray *optionsArray in [optionDict allValues]) {
            if ([optionsArray count]) {
                count++;
            }
        }
        
        if (count == 100) {
            valid = YES;
        }
    }
    
    if (valid) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:AlertViewTitleSubmit message:@"确认提交答卷？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"是的", nil];
        [alertView show];
        [alertView autorelease];
    }else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:AlertViewTitleSubmit message:@"有未完成的题目" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续提交", @"查看未完成的题目", nil];
        [alertView show];
        [alertView autorelease];
    }
}

- (IBAction)returnToParent:(id)sender {
    if (![self.record.completed boolValue]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:AlertViewTitleReturn message:@"这会退出本次测验噢~" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"退出并保存进度", @"退出且不保存", nil];
        [alertView show];
        [alertView autorelease];
    }else {
        NSManagedObjectContext *context = [Util managedObjectContext];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.title isEqualToString:AlertViewTitleReturn]) {
        if (buttonIndex != 0) {
            NSManagedObjectContext *context = [Util managedObjectContext];
            
            if (buttonIndex == 2) {
                for (Answer *answer in self.record.answers) {
                    [context deleteObject:answer];
                }
                
                Paper *thePaper = self.record.paper;
                if (![thePaper.isOriginal boolValue]) {
                    [context deleteObject:thePaper];
                }
                
                //delete record
                [context deleteObject:self.record];
            }else {
                //save current context
                [self recordAnswers];
            }
            
            NSError *error = nil;
            if (![context save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if ([alertView.title isEqualToString:AlertViewTitleSubmit]) {
        //TODO: Constructing dummy data for test
//        NSMutableDictionary *dummyDict = [NSMutableDictionary dictionary];
//        for (NSInteger i = 1; i <= 100; ++i) {
//            NSMutableArray *array = [NSMutableArray array];
//            arc4random();
//            
//            NSInteger optionIndex = random() % 3;
//            [array addObject:[NSNumber numberWithInt:optionIndex]];
//            
//            [dummyDict setObject:array forKey:[NSNumber numberWithInt:i]];
//        }
//        
//        
//        //optionDict = dummyDict;
//        scrollerViewController.optionDict = dummyDict;
        //TODO: Constructing dummy data for test
        
        if (1 == buttonIndex) {
            //submit the answers
            self.record.completed = [NSNumber numberWithBool:YES];
            
            [self recordAnswers];
            
            //judge the answers
            [self judgeAnswers];
        }else if (2 == buttonIndex) {
            //show the summary page
            ExamSummaryViewController *controller = [[[ExamSummaryViewController alloc] init] autorelease];
            controller.style = ([self.paper.distributionType intValue] == ValueDistributionTypeOne) ? SummaryStyleOne : SummaryStyleTwo;
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSMutableArray array], [NSMutableArray array], [NSMutableArray array], nil] 
                                                                           forKeys:[NSArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:1], [NSNumber numberWithInt:2], nil]];
            NSDictionary *optionDict = scrollerViewController.optionDict;
            
            for (NSInteger i = 1; i <= 100; ++i) {
                NSNumber *key = [NSNumber numberWithInt:i];
                NSArray *optionArray = [optionDict objectForKey:key];
                BOOL shouldHighlight = ([optionArray count] == 0);
                
                if (shouldHighlight) {
                    NSInteger page = [key intValue];
                    NSInteger section = 0;
                    NSInteger firstSectionNum = ([self.paper.distributionType intValue] == ValueDistributionTypeOne) ? 30 : 50;
                    
                    if (page > firstSectionNum && page <= 80) {
                        section = 1;
                    }else if (page > 80) {
                        section = 2;
                    }
                    
                    NSMutableArray *sectionArray = [dict objectForKey:[NSNumber numberWithInt:section]];
                    [sectionArray addObject:[NSNumber numberWithInt:page]];
                }
            }
            
            controller.highlightDict = dict;
            controller.delegate = (NSObject<ExamSummaryDelegate>*)self;
            
            controller.modalPresentationStyle = UIModalPresentationFormSheet;
            controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            
            [self presentModalViewController:controller animated:YES];
        }
    }
}

#pragma mark - UIAlertView Delegate
- (void)judgeAnswers{
    PaperResult *result = [PaperJudge judge:record];
    
    PaperResultViewController *controller = [[[PaperResultViewController alloc] init] autorelease];
    controller.resultInfo = result;
    controller.delegate = (NSObject<ExamSummaryDelegate>*)self;
    
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
    
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
    navController.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    
    [self presentModalViewController:navController animated:YES];
    
    if ([timer isValid]) {
        [timer invalidate];
        timer = nil;
    }
    
    self.record.completed = [NSNumber numberWithInt:YES];
    initialized = NO;
    
    [scrollerViewController clear];
    [self viewWillAppear:NO];
    
    //update 
}

- (void)recordAnswers{
    NSTimeInterval leftTime = [self.dedlineTime timeIntervalSinceDate:[NSDate date]];
    self.record.leftTime = [NSNumber numberWithDouble:leftTime];
    self.record.lastPage = [NSNumber numberWithInt:pageSelector.currentPage];
    
    [self.record removeAnswers:self.record.answers];
    NSManagedObjectContext *managedObjectContext = [Util managedObjectContext];
    
    //Insert answers and attach to the record
    NSDictionary *dict = [scrollerViewController optionDict];
    
    for (NSNumber *pageNum in [dict allKeys]) {
        NSInteger page = [pageNum intValue];
        NSArray *optionList = [dict objectForKey:pageNum];
        
        if ([optionList count]) {
            Question *question = [scrollerViewController questionByPage:page];
            Answer *answer = (Answer*)[NSEntityDescription insertNewObjectForEntityForName:EntityNameAnswer inManagedObjectContext:managedObjectContext];
            answer.question = question;
            answer.paper = self.paper;
            answer.Id = [NSNumber numberWithInt:page];
            
            NSArray *options = [question.options allObjects];
            for (NSNumber *indexNum in optionList) {
                NSInteger index = [indexNum intValue];
                Option *option = [options objectAtIndex:index];
                
                [answer addOptionsObject:option];
            }
            
            [self.record addAnswersObject:answer];
        }
    }
}

- (Bookmark*)bookmarkOfPage:(NSInteger)page{
    Question *question = [scrollerViewController questionByPage:page];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:EntityNameBookmark 
                                              inManagedObjectContext:[Util managedObjectContext]];
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"itemType" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:descriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [descriptor release];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %d", @"itemId", [question.Id intValue]];
    [fetchRequest setPredicate:predicate];
    
    NSArray *bookmarks = [[Util managedObjectContext] executeFetchRequest:fetchRequest error:nil];
    
    Bookmark *bookmark = nil;
    if ([bookmarks count]) {
        bookmark = [bookmarks objectAtIndex:0];
    }

    return bookmark;
}

- (void)didSelectItemForPage:(NSInteger)page{
    [self dismissModalViewControllerAnimated:YES];
    pageSelector.currentPage = page;
}

- (void)dismissSummaryInfo{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)dismissAnalysis{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)updateTime:(NSTimer*)theTimer{
    NSDate *date = [NSDate date];
    NSUInteger flags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:flags fromDate:date toDate:self.dedlineTime options:0];
    NSString *titleString = [NSString stringWithFormat:@"%d:%d:%d", [components hour], [components minute], [components second]];
    self.timeItem.title = titleString;
}

- (void)showAnalysis{
    AnalysisViewController *controller = [[[AnalysisViewController alloc] init] autorelease];
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
    
    Question *question = [scrollerViewController questionByPage:pageSelector.currentPage];
    controller.question = question;
    controller.delegate = (NSObject<AnalysisViewControllerDelegates>*)self;
    
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentModalViewController:navController animated:YES];
}
@end
