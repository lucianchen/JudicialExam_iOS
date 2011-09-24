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
    UITableView *tableView;
    UITableViewCell *addOptionCell;
    UITextView *descView;
    UITableViewCell *titleCell;
    UITableViewCell *descCell;
    UITableViewCell *tmpCell;
    NSMutableArray *options;
}

@property(nonatomic, assign) NSObject<QuestionEditViewControllerDelegate> *delegate;
@property(nonatomic, retain) Question *question;
@property (nonatomic, retain) IBOutlet UITextView *titleView;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UITableViewCell *addOptionCell;
@property (nonatomic, retain) IBOutlet UITextView *descView;
@property (nonatomic, retain) IBOutlet UITableViewCell *titleCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *descCell;
@property (nonatomic, assign) IBOutlet UITableViewCell *tmpCell;

- (IBAction)addOption:(id)sender;

@end
