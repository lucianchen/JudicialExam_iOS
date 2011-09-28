//
//  AnalysisViewController.h
//  JudicialExam
//
//  Created by Chen, Liang on 9/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Question.h"

@protocol AnalysisViewControllerDelegates
- (void)dismissAnalysis;
@end

@interface AnalysisViewController : UIViewController{
    Question *question;
    UITextView *analysisView;
    NSObject<AnalysisViewControllerDelegates> *delegate;
}

@property(nonatomic, assign) Question *question;
@property (nonatomic, retain) IBOutlet UITextView *analysisView;
@property (nonatomic, assign) NSObject<AnalysisViewControllerDelegates> *delegate;

@end
