//
//  QuestionListViewController.h
//  JudicialExam
//
//  Created by Chen Liang on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface QuestionListViewController : UIViewController {
    NSFetchedResultsController *fetchedResultsController;
    UITableView *questionTableView;
    UISegmentedControl *yearControl;
    UISegmentedControl *paperTypeControl;
    UITableViewCell *tmpCell;
}

@property (nonatomic, retain) IBOutlet UISegmentedControl *yearControl;
@property (nonatomic, retain) IBOutlet UISegmentedControl *paperTypeControl;
@property (nonatomic, retain) IBOutlet UITableView *questionTableView;
@property (nonatomic, assign) IBOutlet UITableViewCell *tmpCell;

- (IBAction)generateData:(id)sender;
- (IBAction)yearChanged:(id)sender;
- (IBAction)paperTypeChanged:(id)sender;

@end
