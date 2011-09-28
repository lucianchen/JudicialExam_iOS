//
//  ExaminationViewController.m
//  JudicialExam
//
//  Created by Chen Liang on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ExaminationViewController.h"
#import "ExamPreConfigViewController.h"
#import "PaperGenerator.h"
#import "Util.h"
#import "ExamPaperViewController.h"
#import "Record.h"
#import "Constants.h"

#define AlertViewTitleStartTest @"开始测试"

@interface ExaminationViewController()
- (void)updateUI;
@end

@implementation ExaminationViewController
@synthesize continueButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [continueButton release];
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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setContinueButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self updateUI];
}

- (void)updateUI{
    BOOL shouldShowContinueButton = NO;
    Record *lastRecord = [Util lastRecord];
    
    if (lastRecord && !lastRecord.completed) {
        shouldShowContinueButton = YES;
    }
    
    self.continueButton.hidden = !shouldShowContinueButton;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (IBAction)startTest:(id)sender {
    BOOL shouldAlert = NO;
    Record *lastRecord = [Util lastRecord];
    
    if (lastRecord && !lastRecord.completed) {
        shouldAlert = YES;
    }
    
    if (shouldAlert) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:AlertViewTitleStartTest message:@"开始新的测验会删除上次保存的进度噢~" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"开始新测试", nil];
        [alertView show];
        [alertView autorelease];
    }else {
        ExamPreConfigViewController *controller = [[[ExamPreConfigViewController alloc] init] autorelease];
        controller.delegate = (NSObject<ExamPreConfigViewControllerDelegate>*)self;
        
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
        [self presentModalViewController:controller animated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.title isEqualToString:AlertViewTitleStartTest]) {
        if (buttonIndex != 0) {
            NSManagedObjectContext *context = [Util managedObjectContext];
            
            if (buttonIndex == 1) {
                //delete record
                Record *lastRecord = [Util lastRecord];
                [context deleteObject:lastRecord];
            }
            
            NSError *error = nil;
            if (![context save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            
            [self startTest:nil];
            [self updateUI];
        }
    }
}

- (IBAction)continueTest:(id)sender {
    Record *record = [Util lastRecord];
    
    if (record && !record.completed) {
        ExamPaperViewController *controller = [[[ExamPaperViewController alloc] init] autorelease];
        controller.record = record;
        controller.paper = record.paper;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)didEndConfiguration:(BOOL)shouldStart settings:(ExamPreSettings)settings{
    if (shouldStart) {
        PaperGenerator *paperGenerator = [[[PaperGenerator alloc] init] autorelease];
        Paper *paper = [paperGenerator paperFromSettings:settings];
        
        NSManagedObjectContext *context = [Util managedObjectContext];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        ExamPaperViewController *controller = [[[ExamPaperViewController alloc] init] autorelease];
        controller.paper = paper;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}


@end
