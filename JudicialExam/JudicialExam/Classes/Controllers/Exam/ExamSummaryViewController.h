//
//  ExamSummaryViewController.h
//  JudicialExam
//
//  Created by Chen, Liang on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SummaryProtocol.h"

typedef enum {
    SummaryStyleOne = 0,
    SummaryStyleTwo
}SummaryStyle;



@interface ExamSummaryViewController : UIViewController{
    UITableView *summaryTableView;
    UITableViewCell *sectionOneCell;
    UITableViewCell *sectionTwoCell;
    UITableViewCell *sectionThreeCell;
    NSDictionary *highlightDict;
    NSObject<ExamSummaryDelegate> *delegate;
    BOOL historyMode;
    UILabel *hintLabel;
    SummaryStyle style;
}

@property (nonatomic, retain) IBOutlet UILabel *hintLabel;
@property(nonatomic, retain) IBOutlet UITableView *summaryTableView;
@property (nonatomic, retain) IBOutlet UITableViewCell *sectionOneCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *sectionTwoCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *sectionThreeCell;
@property (nonatomic, retain) NSDictionary *highlightDict;
@property (nonatomic, assign) NSObject<ExamSummaryDelegate> *delegate;
@property (nonatomic, assign) BOOL historyMode;
@property (nonatomic, assign) SummaryStyle style;

- (IBAction)cellSelected:(id)sender;

@end
