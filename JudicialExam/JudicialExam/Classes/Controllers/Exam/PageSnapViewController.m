//
//  PageSnapViewController.m
//  JudicialExam
//
//  Created by Chen, Liang on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PageSnapViewController.h"
#import "PaperQuestionView.h"
#import <QuartzCore/QuartzCore.h>
#import "CellUtil.h"

@interface PageSnapViewController()

- (void)refreshThumbnail;
- (CGPoint)thumbnailViewCenter;
- (void)setStyleForPageView:(PaperQuestionView*)page;
@end

@implementation PageSnapViewController
@synthesize pageSelector;
@synthesize snapView;
@synthesize activityView;
@synthesize  showSnapView;
@synthesize showPopupThumbnail;
@synthesize thumbnailView, thumbPageView;
@synthesize pageSlider, thumbPageLabel;

- (void)dealloc{
    [pageSelector release];
    [snapView release];
	[activityView release];
	[thumbnailView release];
	[pageSlider release];
	[thumbPageView release];
	[thumbPageLabel release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.showSnapView = NO;
	
	[self.activityView startAnimating];
	
	[self setStyleForPageView:self.thumbPageView];
    
	self.thumbPageLabel.layer.cornerRadius = 4;
	self.thumbPageLabel.layer.masksToBounds = YES;
	
	self.thumbnailView.hidden = YES;
	self.thumbPageLabel.text = [NSString stringWithFormat:@"%d", 1];;
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

- (void)setPageSelector:(PaperPageSelector *)selector{
    [pageSelector autorelease];
    pageSelector = [selector retain];
    
    [pageSelector addPageObserver:self selector:@selector(pageSelectionDidChange:)];
}

- (void)pageSelectionDidChange:(NSNotification*)notification{
    NSInteger totalPageNum = pageSelector.totalPage;
    NSInteger page = pageSelector.currentPage;
    
    self.thumbPageLabel.text = [NSString stringWithFormat:@"%d",page];
    
    if (!pageSlider.touchInside && (totalPageNum > 1)) {
        CGFloat value = (float)(page - 1) / (float)(totalPageNum - 1);
        pageSlider.value = value;
    }else {
        [self refreshThumbnail];
    }
}

- (void)setStyleForPageView:(PaperQuestionView*)page{
	page.layer.cornerRadius = 4;
	//page.layer.masksToBounds = YES;
	page.layer.borderColor = [[UIColor grayColor] CGColor];
	page.layer.borderWidth = 0.5;
	page.layer.shadowColor = [[UIColor blackColor] CGColor];
	page.layer.shadowOpacity = 0.5;
	page.layer.shadowOffset = CGSizeMake(5, 5);
}

- (IBAction)sliderDidSlide:(id)sender{
	self.thumbnailView.center = [self thumbnailViewCenter];
    
    NSInteger curPage = nearbyint(1 + self.pageSlider.value * (pageSelector.totalPage - 1));
    self.thumbPageLabel.text = [NSString stringWithFormat:@"%d",curPage];
}

- (IBAction)sliderDidTouchDown{
	self.thumbPageLabel.hidden = NO;
	
    CALayer *layer = self.thumbPageLabel.layer;
    layer.cornerRadius = 4;
	layer.masksToBounds = YES;
	layer.borderColor = [[UIColor grayColor] CGColor];
	layer.borderWidth = 0.5;
	layer.shadowColor = [[UIColor blackColor] CGColor];
	layer.shadowOpacity = 0.5;
	layer.shadowOffset = CGSizeMake(5, 5);
}

- (IBAction)sliderDidTouchUp{
	self.thumbPageLabel.hidden = YES;
    
    NSInteger curPage = nearbyint(1 + self.pageSlider.value * (pageSelector.totalPage - 1));
	
    if (pageSelector.currentPage != curPage) {
        [pageSelector removePageObserver:self];
		pageSelector.currentPage = curPage;
        [pageSelector addPageObserver:self selector:@selector(pageSelectionDidChange:)];
	}
}

- (CGPoint)thumbnailViewCenter{
	//CGRect frame = self.pageSlider.frame;
	CGFloat y = self.thumbnailView.superview.frame.origin.y - self.thumbnailView.frame.size.height / 2 + 10;
	CGFloat x = self.pageSlider.frame.origin.x + CGRectGetMidX([self.pageSlider thumbRectForBounds:self.pageSlider.bounds 
                                                                                         trackRect:[self.pageSlider trackRectForBounds:self.pageSlider.bounds] 
                                                                                             value:self.pageSlider.value]);
	
	CGFloat minX = self.thumbnailView.frame.size.width / 2;
	CGFloat maxX = self.thumbnailView.superview.frame.size.width - self.thumbnailView.frame.size.width / 2;
	if (x < minX) {
		x = minX;
	}else if (x > maxX) {
		x = maxX;
	}
	
	return CGPointMake(x, y);
}

- (void)refreshThumbnail{
	CGRect frame = self.thumbPageView.frame;
    [thumbPageView removeFromSuperview];
    [thumbPageView release];
    thumbPageView = nil;
    thumbPageView = [[PaperQuestionView alloc] initWithFrame:frame];
    
    [self setStyleForPageView:self.thumbPageLabel];
    [self.thumbnailView addSubview:thumbPageView];
    [self.thumbnailView bringSubviewToFront:thumbPageLabel];
    
    //[self.thumbPageView setNeedsDisplay];
}

- (void)setShowSnapView:(BOOL)show{
	if (show) {
		snapView.hidden = NO;
		pageSlider.hidden = YES;
	}else {
		snapView.hidden = YES;
		pageSlider.hidden = NO;
	}
    
	showSnapView = show;
}

@end
