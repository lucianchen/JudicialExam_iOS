//
//  ExamPreConfigViewController.m
//  JudicialExam
//
//  Created by Chen, Liang on 9/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ExamPreConfigViewController.h"
#import "Constants.h"

@interface ExamPreConfigViewController()
@end

@implementation ExamPreConfigViewController
@synthesize questionSourceSegCtrl;
@synthesize includingUserQuestionSwitch;
@synthesize yearPicker;
@synthesize questionTypeSegCtrl;
@synthesize settings;
@synthesize sourceView;
@synthesize userQuestionView;
@synthesize yearView;
@synthesize delegate;

- (void)dealloc{
    
    [sourceView release];
    [userQuestionView release];
    [yearView release];
    [questionTypeSegCtrl release];
    [questionSourceSegCtrl release];
    [includingUserQuestionSwitch release];
    [yearPicker release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.questionSourceSegCtrl.selectedSegmentIndex = 1;
}

- (void)viewDidUnload
{
    [self setSourceView:nil];
    [self setUserQuestionView:nil];
    [self setYearView:nil];
    [self setQuestionTypeSegCtrl:nil];
    [self setQuestionSourceSegCtrl:nil];
    [self setIncludingUserQuestionSwitch:nil];
    [self setYearPicker:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)hideyearView{
    self.yearView.hidden = YES;
}

- (void)hideUserQuestionView{
    self.userQuestionView.hidden = YES;
}

- (IBAction)sourceChanged:(id)sender {
    NSInteger index = self.questionSourceSegCtrl.selectedSegmentIndex;
    if (index == 0) {
        self.userQuestionView.hidden = NO;
        
        self.userQuestionView.alpha = 0;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.5];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDidStopSelector:@selector(hideyearView)];
        [UIView setAnimationDelegate:self];
        
        self.userQuestionView.alpha = 1;
        self.yearView.alpha = 0;
        
        [UIView commitAnimations];
    }else {
        self.yearView.hidden = NO;
        self.yearView.alpha = 0;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.5];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDidStopSelector:@selector(hideUserQuestionView)];
        [UIView setAnimationDelegate:self];
        
        self.yearView.alpha = 1;
        self.userQuestionView.alpha = 0;
        
        [UIView commitAnimations];
    }
}

- (IBAction)done:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didEndConfiguration:settings:)]) {
        [self.delegate didEndConfiguration:YES settings:self.settings];
    }
}

- (IBAction)cancel:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didEndConfiguration:settings:)]) {
        [self.delegate didEndConfiguration:NO settings:self.settings];
    }
}

- (ExamPreSettings)settings{
    ExamPreSettings retval;
    
    ExamPaperType paperType = self.questionTypeSegCtrl.selectedSegmentIndex;
    ExamQuestionSourceType sourceType = self.questionSourceSegCtrl.selectedSegmentIndex;
    ExamQuestionYear year = [self.yearPicker selectedRowInComponent:0];
    if (year > 0) {
        year += PaperYearStart - 1;
    }
    
    BOOL includingUserQuestions = self.includingUserQuestionSwitch.on;
    
    retval.paperType = paperType;
    retval.questionSource = sourceType;
    retval.includingUserQuestions = includingUserQuestions;
    retval.year = year;
    
    return retval;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView 
numberOfRowsInComponent:(NSInteger)component{
    return 2 + PaperYearEnd - PaperYearStart;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *retval = nil;
    
    if (0 == row) {
        retval = @"All";
    }else {
        retval = [NSString stringWithFormat:@"%d", PaperYearStart - 1 + row];
    }
    
    return retval;
}

@end
