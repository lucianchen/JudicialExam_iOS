//
//  DataGenerationViewController.h
//  JudicialExam
//
//  Created by Chen, Liang on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataGenerator.h"

@protocol DataGenerationViewControllerDelegate <NSObject>

- (void)dataGenerationDone;

@end

@interface DataGenerationViewController : UIViewController {
    UILabel *statusView;
    UIProgressView *progressView;
    NSObject<DataGenerationViewControllerDelegate> *delegate;
    DataGenerator *dataGenerator;
    UITextView *summaryTextView;
}

@property (nonatomic, retain) IBOutlet UITextView *summaryTextView;

@property (nonatomic, retain) IBOutlet UIProgressView *progressView;
@property (nonatomic, retain) IBOutlet UILabel *statusView;
@property (nonatomic, assign) NSObject<DataGenerationViewControllerDelegate> *delegate;

@end
