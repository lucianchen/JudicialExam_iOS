//
//  OptionEditViewController.h
//  JudicialExam
//
//  Created by Chen, Liang on 9/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Option.h"

@protocol OptionEditViewControllerDelegate <NSObject>

- (void)didSubmitOption:(Option*)option;
- (void)didCancelSubmitting:(Option*)option;

@end

@interface OptionEditViewController : UIViewController{
    NSObject<OptionEditViewControllerDelegate> *delegate;
    Option *option;
    UITextView *textView;
}

@property(nonatomic, assign) NSObject<OptionEditViewControllerDelegate> *delegate;
@property(nonatomic, retain) Option *option;
@property(nonatomic, retain) IBOutlet UITextView *textView;

@end
