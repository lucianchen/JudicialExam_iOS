//
//  PaperQuestionView.h
//  JudicialExam
//
//  Created by Chen, Liang on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaperQuestionView : UIView{
	NSInteger index;
	CGRect adjustedFrame;
}

@property(nonatomic, assign) NSInteger index;
@property(nonatomic, readonly) CGRect contentFrame;

- (void)display;
- (void)prepareDetailView;
- (void)cleanup;
- (void)reLayout;
- (CGRect)adjustedContentFrame;

- (NSComparisonResult)distanceCompare:(PaperQuestionView*)scrollView;
- (void)prepareDetailView;

@end
