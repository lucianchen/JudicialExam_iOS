//
//  PageSnapViewController.h
//  JudicialExam
//
//  Created by Chen, Liang on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaperPageSelector.h"
#import "PageSnapView.h"
#import "PaperQuestionView.h"

@interface PageSnapViewController : UIViewController{
    PaperPageSelector *pageSelector;
	CGPDFDocumentRef pdfRef;
	UIActivityIndicatorView *activityView;
	PageSnapView *snapView;
	BOOL showSnapView;
	BOOL showPopupThumbnail;
	UIView *thumbnailView;
	PaperQuestionView *thumbPageView;
	UILabel *thumbPageLabel;
	UISlider *pageSlider;
}

@property(nonatomic, retain) PaperPageSelector *pageSelector;
@property(nonatomic, retain) IBOutlet PageSnapView *snapView;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *activityView;
@property(nonatomic, retain) IBOutlet UIView *thumbnailView;
@property(nonatomic, retain) IBOutlet PaperQuestionView *thumbPageView;
@property(nonatomic, retain) IBOutlet UISlider *pageSlider;
@property(nonatomic, retain) IBOutlet UILabel *thumbPageLabel;

@property(nonatomic, assign) BOOL showSnapView;
@property(nonatomic, assign) BOOL showPopupThumbnail;

- (IBAction)sliderDidSlide:(id)sender;
- (IBAction)sliderDidTouchDown;
- (IBAction)sliderDidTouchUp;

@end
