//
//  QuestionEditViewController.h
//  JudicialExam
//
//  Created by Chen Liang on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Question.h"

@protocol QuestionEditViewControllerDelegate <NSObject>

- (void)didSubmitQuestion:(Question*)question;
- (void)didCancelSubmitting;

@end

@interface QuestionEditViewController : UIViewController {
    NSObject<QuestionEditViewControllerDelegate> *delegate;
    Question *question;
    UITextView *titleView;
    UITableView *optionsTableView;
    UITextView *descView;
}

@property(nonatomic, assign) NSObject<QuestionEditViewControllerDelegate> *delegate;
@property(nonatomic, retain) Question *question;
@property (nonatomic, retain) IBOutlet UITextView *titleView;
@property (nonatomic, retain) IBOutlet UITableView *optionsTableView;
@property (nonatomic, retain) IBOutlet UITextView *descView;

@end
