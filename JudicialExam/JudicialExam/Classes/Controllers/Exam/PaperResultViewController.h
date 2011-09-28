//
//  PaperResultViewController.h
//  JudicialExam
//
//  Created by Chen, Liang on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaperResult.h"
#import "SummaryProtocol.h"
#import "ExamSummaryViewController.h"

@interface PaperResultViewController : UIViewController {
    UIView *summaryContainer;
    UILabel *scoreLabel;
    UILabel *ratioLabel;
    UILabel *fullMarkLabel;
    UIView *resultView;
    PaperResult *resultInfo;
    NSObject<ExamSummaryDelegate> *delegate;
    
    ExamSummaryViewController *summaryViewController;
}

@property (nonatomic, retain) IBOutlet UIView *resultView;

@property (nonatomic, retain) IBOutlet UIView *summaryContainer;
@property (nonatomic, retain) IBOutlet UILabel *scoreLabel;
@property (nonatomic, retain) IBOutlet UILabel *ratioLabel;
@property (nonatomic, retain) IBOutlet UILabel *fullMarkLabel;
@property (nonatomic, retain) PaperResult *resultInfo;
@property (nonatomic, assign) NSObject<ExamSummaryDelegate> *delegate;

@end
