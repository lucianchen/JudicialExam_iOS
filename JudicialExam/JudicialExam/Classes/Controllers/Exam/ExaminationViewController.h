//
//  ExaminationViewController.h
//  JudicialExam
//
//  Created by Chen Liang on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ExaminationViewController : UIViewController {
    UIButton *continueButton;
}
@property (nonatomic, retain) IBOutlet UIButton *continueButton;

- (IBAction)startTest:(id)sender;
- (IBAction)continueTest:(id)sender;

@end
