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
    UITableView *tableView;
    UIButton *questionTypeButton;
    UILabel *questionTypeLabel;
    UIImageView *backView;
}

@property (nonatomic, retain) IBOutlet UIImageView *backView;
@property(nonatomic, assign) NSInteger index;
@property(nonatomic, readonly) CGRect contentFrame;
@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIButton *questionTypeButton;
@property (nonatomic, retain) IBOutlet UILabel *questionTypeLabel;

- (void)display;
- (void)prepareDetailView;
- (void)cleanup;
- (void)reLayout;
- (CGRect)adjustedContentFrame;

- (NSComparisonResult)distanceCompare:(PaperQuestionView*)scrollView;
- (void)prepareDetailView;

@end
