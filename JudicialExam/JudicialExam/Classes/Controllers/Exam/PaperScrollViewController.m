//
//  PaperScrollViewController.m
//  JudicialExam
//
//  Created by Chen, Liang on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PaperScrollViewController.h"
#import "PaperQuestionView.h"
#import "Question.h"
#import <QuartzCore/QuartzCore.h>
#import "CellUtil.h"
#import "Types.h"

#define BUFFER_PAGE_SIZE (2)

@interface PaperScrollViewController()

- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (NSError*)loadDocument:(CGPDFDocumentRef*)docRefPointer;
- (void)layoutPages;
- (NSArray*)visiblePages:(NSInteger)currentPage;
- (PaperQuestionView *)anyRecycledPage;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;
- (void)configurePage:(PaperQuestionView *)page forIndex:(NSUInteger)index;
- (IBAction)handleDoubleTap:(UIGestureRecognizer *)sender;
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center scrollView:(UIScrollView*)view;
- (PaperQuestionView*)currentView;

- (void)pageSelectionDidChange:(NSNotification*)notification;
- (NSString*)typeStringWithType:(QuestionType)type;
- (NSString*)typeDescStringWithType:(QuestionType)type;
- (NSMutableArray*)optionArrayForPage:(NSInteger)page;
- (QuestionType)questionTypeByQuestionId:(NSInteger)Id;

- (void)layoutPagesByPageSelector;
- (void)layoutPagesWithFistIndex:(NSInteger)firstNeededPageIndex lastIndex:(NSInteger)lastNeededPageIndex;

@end

@implementation PaperScrollViewController
@synthesize pageSelector;
@synthesize record;
@synthesize paper;
@synthesize tmpCell;
@synthesize tmpQuestionView;
@synthesize optionDict;

- (void)dealloc{
    [pageSelector release];
    [recycledPages release];
    [visiblePages release];
    
    [pagingScrollView release];
    
    [optionDict release];
    
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
    
    firstNeededIndex = NSNotFound;
	lastNeededIndex = NSNotFound;
	pagingScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
	recycledPages = [[NSMutableArray alloc] init];
	visiblePages  = [[NSMutableArray alloc] init];
    
    pagingScrollView.delegate = (id<UIScrollViewDelegate>)self;
    
    if (!optionDict) {
        optionDict = [[NSMutableDictionary alloc] init];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    pagingScrollView.frame = pagingScrollViewFrame;
    pagingScrollView.contentSize = CGSizeMake(pagingScrollViewFrame.size.width * pageSelector.totalPage,
                                              pagingScrollViewFrame.size.height);
    
    [self layoutPagesByPageSelector];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
										 duration:(NSTimeInterval)duration
{
	//[recycledPages addObjectsFromArray:visiblePages];
    //	[visiblePages removeAllObjects];
	
	CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
	pagingScrollView.frame = pagingScrollViewFrame;
	pagingScrollView.contentSize = CGSizeMake(pagingScrollViewFrame.size.width * pageSelector.totalPage,
											  pagingScrollViewFrame.size.height);
	CGPoint offset = pagingScrollView.contentOffset;
	offset.x = (pageSelector.currentPage - 1) * pagingScrollViewFrame.size.width;
	pagingScrollView.contentOffset = offset;
	
	for (PaperQuestionView *page in visiblePages) {
		page.frame = [self frameForPageAtIndex:page.index];
		//[page reLayout];
	}
	
	[self layoutPages];
}

- (void)clear{
    NSArray *pages = [NSArray arrayWithArray:visiblePages];
	for (PaperQuestionView *page in pages) {
		[visiblePages removeObject:page];
        [page removeFromSuperview];
	}
}

- (void)setPageSelector:(PaperPageSelector *)selector{
    [pageSelector autorelease];
    pageSelector = [selector retain];
    
    [pageSelector addPageObserver:self selector:@selector(pageSelectionDidChange:)];
}

#pragma mark -
#pragma mark ScrollView delegate methods
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{	
	NSInteger curIndex = pagingScrollView.contentOffset.x / CGRectGetWidth(pagingScrollView.bounds);
	//current page settings
	if (pageSelector.currentPage != curIndex + 1) {
        [pageSelector removePageObserver:self];
		pageSelector.currentPage = curIndex + 1;
        [pageSelector addPageObserver:self selector:@selector(pageSelectionDidChange:)];
	}
    
    [self layoutPages];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSInteger curIndex = pagingScrollView.contentOffset.x / CGRectGetWidth(pagingScrollView.bounds);
    
    int firstNeededPageIndex = curIndex - BUFFER_PAGE_SIZE > 0 ? (curIndex - BUFFER_PAGE_SIZE) : 0;
    int lastNeededPageIndex = curIndex + BUFFER_PAGE_SIZE >= pageSelector.totalPage - 1 ? pageSelector.totalPage - 1 : (curIndex + BUFFER_PAGE_SIZE);
    
    if ((curIndex + 1 != pageSelector.currentPage) && 
        ((firstNeededPageIndex != firstNeededIndex) || (lastNeededPageIndex != lastNeededIndex))) {
        
        //        [pageSelector removePageObserver:self];
        //		pageSelector.currentPage = curIndex + 1;
        //        [pageSelector addPageObserver:self selector:@selector(pageSelectionDidChange:)];
        
        [self layoutPages];
    }
    
    firstNeededIndex = firstNeededPageIndex;
    lastNeededIndex = lastNeededPageIndex;
}

- (void)pageSelectionDidChange:(NSNotification*)notification{
    //
    [self layoutPagesByPageSelector];
    
    [self performSelector:@selector(layoutPages) withObject:nil afterDelay:0.3];
}

- (void)layoutPages{
	// Calculate which pages are visible
	CGRect visibleBounds = pagingScrollView.bounds;
	NSInteger curIndex = pagingScrollView.contentOffset.x / CGRectGetWidth(visibleBounds);
    NSInteger pageNum = pageSelector.totalPage;
	
	int firstNeededPageIndex = curIndex - BUFFER_PAGE_SIZE > 0 ? (curIndex - BUFFER_PAGE_SIZE) : 0;
	int lastNeededPageIndex  = curIndex + BUFFER_PAGE_SIZE >= pageNum - 1 ? pageNum - 1 : (curIndex + BUFFER_PAGE_SIZE);

	firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
	lastNeededPageIndex  = MIN(lastNeededPageIndex, pageNum - 1);
    
	
	[self layoutPagesWithFistIndex:firstNeededPageIndex lastIndex:lastNeededPageIndex];
}

- (void)layoutPagesByPageSelector{
    CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    CGPoint offset = pagingScrollView.contentOffset;
    offset.x = (pageSelector.currentPage - 1) * pagingScrollViewFrame.size.width;
    
    //CGRect frame = [self frameForPageAtIndex:pageSelector.currentPage - 1];
    //[pagingScrollView scrollRectToVisible:frame animated:YES];
    [pagingScrollView setContentOffset:offset animated:YES];
    
    NSInteger pageNum = pageSelector.totalPage;
    NSInteger curIndex = pageSelector.currentPage - 1;
    int firstNeededPageIndex = curIndex - BUFFER_PAGE_SIZE > 0 ? (curIndex - BUFFER_PAGE_SIZE) : 0;
	int lastNeededPageIndex  = curIndex + BUFFER_PAGE_SIZE >= pageNum - 1 ? pageNum - 1 : (curIndex + BUFFER_PAGE_SIZE);
    [self layoutPagesWithFistIndex:firstNeededPageIndex lastIndex:lastNeededPageIndex];
}

- (void)layoutPagesWithFistIndex:(NSInteger)firstNeededPageIndex lastIndex:(NSInteger)lastNeededPageIndex{
    // Recycle no-longer-visible pages 
    
    NSArray *pages = [NSArray arrayWithArray:visiblePages];
	for (PaperQuestionView *page in pages) {
		if (page.index < firstNeededPageIndex || page.index > lastNeededPageIndex) {
			[recycledPages addObject:page];
            [visiblePages removeObject:page];
            
			[page removeFromSuperview];
			NSLog(@"page removed index: %d", page.index);
		}else {
            [page setNeedsDisplay];
        }
	}
    
	// add missing pages
	for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
		if (![self isDisplayingPageForIndex:index]) {
			//NSLog(@"current offset: %f, pageindex: %d", pagingScrollView.contentOffset.x, index);
			PaperQuestionView *page = [self anyRecycledPage];
			BOOL hasRecycledPage = YES;
			if (page == nil) {
				[[NSBundle mainBundle] loadNibNamed:@"PaperQuestionView" owner:self options:nil];
                page = [self.tmpQuestionView retain];
                page.tableView.backgroundColor = [UIColor clearColor];
                
				hasRecycledPage = NO;
			}else {
                NSLog(@"");
            }
            
            page.tableView.tag = index;
            Question *question = [self questionByPage:page.tableView.tag + 1];
            [page.questionTypeButton setTitle:[self typeStringWithType:[question.optionType intValue]] forState:UIControlStateNormal];
            [page.questionTypeLabel setText:[self typeDescStringWithType:[question.optionType intValue]]];
            
            [page.tableView reloadData];
			
			[self configurePage:page forIndex:index];
			NSLog(@"[Scrollview] Add subview for page: %d", page.index + 1);
			[pagingScrollView addSubview:page];
			[visiblePages addObject:page];
			[page release];
		}
	}
}

- (PaperQuestionView *)anyRecycledPage
{
	PaperQuestionView *page = nil;
	if ([recycledPages count]) {
		page = [[recycledPages lastObject] retain];
	}
	
	if (page) {
		[recycledPages removeObject:page];
	}
	return page;
}

- (void)configurePage:(PaperQuestionView *)page forIndex:(NSUInteger)index
{
	page.index = index;
	page.frame = [self frameForPageAtIndex:index];
    
    CALayer *layer = page.backView.layer;
    layer.borderColor = [[UIColor darkGrayColor] CGColor];
    layer.borderWidth = 0.5;
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowOpacity = 0.5;
    layer.shadowOffset = CGSizeMake(10, 10);
    layer.shadowPath = [UIBezierPath bezierPathWithRect:page.backView.bounds].CGPath;
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index
{
	BOOL foundPage = NO;
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %d", 
							  @"index", index];
	NSArray *searchResult = [visiblePages filteredArrayUsingPredicate:predicate];
	if ([searchResult count]) {
		foundPage = YES;
	}
    
	return foundPage;
}

- (NSArray*)visiblePages:(NSInteger)currentPage{
	NSMutableArray *retval = [NSMutableArray arrayWithObject:[NSNumber numberWithInt:currentPage]];
	if (currentPage >0) {
		[retval addObject:[NSNumber numberWithInt:currentPage - 1]];
	}
	if (currentPage < pageSelector.totalPage) {
		[retval addObject:[NSNumber numberWithInt:currentPage + 1]];
	}
	
	return visiblePages;
}

#pragma mark -
#pragma mark  Frame calculations
#define PADDING  10

- (CGRect)frameForPagingScrollView {
    CGRect frame = [self.view bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return frame;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    
    CGRect pageFrame = pagingScrollViewFrame;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (pagingScrollViewFrame.size.width * index) + PADDING;
    return pageFrame;
}

- (PaperQuestionView*)currentView{
	PaperQuestionView *view = nil;
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %d", 
							  @"index", pageSelector.currentPage - 1];
	NSArray *searchResult = [visiblePages filteredArrayUsingPredicate:predicate];
	if ([searchResult count]) {
		view = [searchResult objectAtIndex:0];
	}
	
	return view;
}

- (Question*)questionByPage:(NSInteger)page{
    return [[self.paper sortedQuestions] objectAtIndex:page - 1];
}

#pragma mark -
#pragma mark Table view data source methods

/*
 The data source methods are handled primarily by the fetch results controller
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger retval = 0;
    
    //Question *question = [self questionByPage:tableView.tag + 1];
    //NSLog(@"Question: %@-%@-%@ Tableview tag: %d", question.year, question.paperType, question.questionId, tableView.tag);
    
    if (0 == section) {
        retval = 1;
    }else {
        retval = [[[self questionByPage:tableView.tag + 1] options] count];
    }
    
    return retval;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *TitleCellIdentifier = @"QuestionListCell";
    static NSString *OptionCellIdentifier = @"OptionCell";
    
    NSString *cellIdentifier = indexPath.section == 0 ? TitleCellIdentifier : OptionCellIdentifier;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = self.tmpCell;
        self.tmpCell = nil;
        
        cell.layer.shouldRasterize = YES;
        cell.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    }
    
    Question *question = [self questionByPage:tableView.tag + 1];
    if ([cellIdentifier isEqualToString:TitleCellIdentifier]) {
        [CellUtil configureCell:(QuestionListCell*)cell forQuestion:question];
        ((QuestionListCell*)cell).idLabel.text = [NSString stringWithFormat:@"%d", tableView.tag + 1];
    }else {
        Option *option = [[question.options allObjects] objectAtIndex:indexPath.row];
        [CellUtil configureCell:(OptionCell*)cell forOption:option];
        
        NSMutableArray *optionArray = [self optionArrayForPage:tableView.tag + 1];
        BOOL hasOption = [optionArray containsObject:[NSNumber numberWithInt:indexPath.row]];
        ((OptionCell*)cell).checkButton.selected = hasOption;
        ((OptionCell*)cell).checkButton.userInteractionEnabled = ![self.record.completed boolValue];
    }
    
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// Display the authors' names as section headings.
    NSString *retval = nil;
    
    if (0 == section) {
        retval = @"题目";
    }else if (1 == section) {
        retval = @"选项";
    }
    
    return retval;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat retval = 160;
    
    if (indexPath.section == 1) {
        retval = 80;
    }
    
    return retval;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![self.record.completed boolValue] && indexPath.section == 1) {
        return indexPath;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.section == 1) {
        NSInteger page = tableView.tag + 1;
        NSInteger selectedOptionIndex = indexPath.row;
        
        NSMutableArray *optionArray = [self optionArrayForPage:page];
        QuestionType type = [self questionTypeByQuestionId:page];
        
        BOOL hasBeenChosen = [optionArray indexOfObject:[NSNumber numberWithInt:selectedOptionIndex]] != NSNotFound;
        if (hasBeenChosen) {
            [optionArray removeObject:[NSNumber numberWithInt:selectedOptionIndex]];
        }else {
            BOOL shouldDeselectFormer = NO;
            NSInteger chosenIndex = NSNotFound;
            
            if (QuestionTypeSingle == type) {
                
                if ([optionArray count]) {
                    chosenIndex = [[optionArray objectAtIndex:0] intValue];
                    shouldDeselectFormer = (chosenIndex != selectedOptionIndex);
                }
            }
            
            if (shouldDeselectFormer) {
                [optionArray removeObject:[NSNumber numberWithInt:chosenIndex]];
                
                [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:chosenIndex inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
            }
            
            [optionArray addObject:[NSNumber numberWithInt:selectedOptionIndex]];
        }
        
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (NSString*)typeStringWithType:(QuestionType)type{
    NSString *retval = nil;
    
    switch (type) {
        case QuestionTypeSingle:
            retval = @"单项选择题";
            break;
        case QuestionTypeMulti:
            retval = @"多项选择题";
            break;
        case QuestionTypeUndefined:
            retval = @"不定项选择题";
            break;
        default:
            break;
    }
    
    return retval;
}

- (NSString*)typeDescStringWithType:(QuestionType)type{
    NSString *retval = nil;
    
    switch (type) {
        case QuestionTypeSingle:
            retval = @"每题所给选项中只有一个正确答案。本部分1—50题，每题1分，共50分。";
            break;
        case QuestionTypeMulti:
            retval = @"每题所给选项中有两个或两个以上正确答案，少答或多答均不得分。本部分51－80题，每题2分，共60分。";
            break;
        case QuestionTypeUndefined:
            retval = @"每题所给选项中有一个或一个以上正确答案，少答或多答均不得分。本部分81—100题，每题2分，共40分。";
            break;
        default:
            break;
    }
    
    return retval;
}

- (NSMutableArray*)optionArrayForPage:(NSInteger)page{
    NSMutableArray *retval = [optionDict objectForKey:[NSNumber numberWithInt:page]];
    
    if (!retval) {
        retval = [NSMutableArray array];
        [optionDict setObject:retval forKey:[NSNumber numberWithInt:page]];
    }
    
    return retval;
}

- (QuestionType)questionTypeByQuestionId:(NSInteger)Id{
    QuestionType retval = QuestionTypeSingle;
    
    if (Id > 50 && Id < 81) {
        retval = QuestionTypeMulti;
    }else if (Id > 80) {
        retval = QuestionTypeUndefined;
    }
    
    return retval;
}

@end
