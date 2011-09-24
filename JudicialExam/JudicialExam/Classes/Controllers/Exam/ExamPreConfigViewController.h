//
//  ExamPreConfigViewController.h
//  JudicialExam
//
//  Created by Chen, Liang on 9/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Types.h"

@protocol ExamPreConfigViewControllerDelegate
- (void)didEndConfiguration:(BOOL)shouldStart settings:(ExamPreSettings)settings;
@end

@interface ExamPreConfigViewController : UIViewController{
    UIView *sourceView;
    UIView *userQuestionView;
    UIView *yearView;
    NSObject<ExamPreConfigViewControllerDelegate> *delegate;
    UISegmentedControl *questionTypeSegCtrl;
    UISegmentedControl *questionSourceSegCtrl;
    UISwitch *includingUserQuestionSwitch;
    UIPickerView *yearPicker;
}
@property (nonatomic, retain) IBOutlet UISegmentedControl *questionSourceSegCtrl;
@property (nonatomic, retain) IBOutlet UISwitch *includingUserQuestionSwitch;
@property (nonatomic, retain) IBOutlet UIPickerView *yearPicker;

@property (nonatomic, retain) IBOutlet UISegmentedControl *questionTypeSegCtrl;
@property(nonatomic, readonly) ExamPreSettings settings;
@property (nonatomic, retain) IBOutlet UIView *sourceView;
@property (nonatomic, retain) IBOutlet UIView *userQuestionView;
@property (nonatomic, retain) IBOutlet UIView *yearView;
@property (nonatomic, assign) NSObject<ExamPreConfigViewControllerDelegate> *delegate;

- (IBAction)sourceChanged:(id)sender;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;
@end
