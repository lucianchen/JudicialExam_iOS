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

@implementation ExaminationViewController

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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (IBAction)startTest:(id)sender {
    ExamPreConfigViewController *controller = [[[ExamPreConfigViewController alloc] init] autorelease];
    controller.delegate = (NSObject<ExamPreConfigViewControllerDelegate>*)self;
    
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentModalViewController:controller animated:YES];
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
    }
    
    [self dismissModalViewControllerAnimated:YES];
}
@end
