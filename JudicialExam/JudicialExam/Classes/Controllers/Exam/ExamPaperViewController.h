//
//  ExamPaperViewController.h
//  JudicialExam
//
//  Created by Chen, Liang on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Paper.h"
#import "PaperScrollViewController.h"
#import "PageSnapViewController.h"
#import "PaperPageSelector.h"

@interface ExamPaperViewController : UIViewController{
    Paper *paper;
    
    float maxWidth;
	UILabel *pageLabel;
	UIButton *backwardButton;
	UIButton *forwardButton;
	UIView *controlPanel;
    
    UIToolbar *topBar;
    UIToolbar *bottomBar;
    
	UIBarButtonItem *bookmarkItem;
	UIBarButtonItem *bookmarkItemReplacement;
    UIBarButtonItem *timeItem;
	UIBarButtonItem *bookmarkItemPlain;
    UIBarButtonItem *answerItem;
    
    PaperScrollViewController *scrollerViewController;
    PageSnapViewController *snapViewController;
    
    PaperPageSelector *pageSelector;
    NSTimer *timer;
    NSDate *dedlineTime;
}

@property(nonatomic, retain) Paper *paper;

@property(nonatomic, retain) IBOutlet UILabel *pageLabel;
@property(nonatomic, retain) IBOutlet UIButton *backwardButton;
@property(nonatomic, retain) IBOutlet UIButton *forwardButton;
@property(nonatomic, retain) IBOutlet UIView *controlPanel;

@property(nonatomic, retain) IBOutlet UIToolbar *topBar;
@property(nonatomic, retain) IBOutlet UIToolbar *bottomBar;

@property(nonatomic, retain) IBOutlet UIBarButtonItem *answerItem;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *bookmarkItem;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *bookmarkItemPlain;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *bookmarkItemReplacement;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *timeItem;

@property(nonatomic, assign) UIGestureRecognizer* gestureRecognizer;

- (IBAction)submit:(id)sender;
@end
