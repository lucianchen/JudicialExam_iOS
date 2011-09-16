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
    NSManagedObjectContext *addingManagedObjectContext;
    UITableView *questionTableView;
}

@property (nonatomic, retain) IBOutlet UITableView *questionTableView;

@end
