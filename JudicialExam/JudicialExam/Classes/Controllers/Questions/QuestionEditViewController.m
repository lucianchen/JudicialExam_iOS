//
//  QuestionEditViewController.m
//  JudicialExam
//
//  Created by Chen Liang on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QuestionEditViewController.h"
#import "OptionEditViewController.h"
#import "Constants.h"
#import "OptionCell.h"

@interface QuestionEditViewController()

- (void)submit;
- (void)cancel;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation QuestionEditViewController
@synthesize delegate;
@synthesize question;
@synthesize titleView;
@synthesize tableView;
@synthesize addOptionCell;
@synthesize descView;
@synthesize titleCell;
@synthesize descCell;
@synthesize tmpCell;

- (void)dealloc
{
    [question release];
    
    [titleView release];
    [tableView release];
    [descView release];
    
    [options release];
    [titleCell release];
    [descCell release];
    [addOptionCell release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStyleDone target:self action:@selector(submit)];
    
    self.titleView.text = self.question.title;
    self.descView.text = self.question.analysis;
    
    if (!options) {
        options = [[NSMutableArray alloc] init];
    }
    [options removeAllObjects];
    
    [options addObjectsFromArray:[self.question.options allObjects]];
}

- (void)viewDidUnload
{
    [self setTitleView:nil];
    [self setTableView:nil];
    [self setDescView:nil];
    [self setTitleCell:nil];
    [self setDescCell:nil];
    [self setAddOptionCell:nil];
    [self setTmpCell:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Actions
- (void)submit{
    if ([self.delegate respondsToSelector:@selector(didSubmitQuestion:)]) {
        self.question.title = self.titleView.text;
        self.question.analysis = self.descView.text;
        
        [self.delegate didSubmitQuestion:self.question];
    }
}

- (void)cancel{
    [self.question.managedObjectContext deleteObject:self.question];
    if ([self.delegate respondsToSelector:@selector(didCancelSubmitting)]) {
        [self.delegate didCancelSubmitting];
    }
}

- (IBAction)addOption:(id)sender{
    OptionEditViewController *controller = [[[OptionEditViewController alloc] init] autorelease];
    
    controller.delegate = (NSObject<OptionEditViewControllerDelegate>*)self;
    
	controller.option = (Option*)[NSEntityDescription insertNewObjectForEntityForName:EntityNameOption inManagedObjectContext:self.question.managedObjectContext];
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Option Edit View Delegate
- (void)didSubmitOption:(Option*)option{
    if (![self.question.options containsObject:option]) {
        [self.question addOptionsObject:option];
        [options addObject:option];
    }
    
    
    NSManagedObjectContext *context = self.question.managedObjectContext;
    NSError *error = nil;
	if (![context save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    
    [self.tableView reloadData];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didCancelSubmitting:(Option*)option{
    [self.question.managedObjectContext deleteObject:option];
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Table view data source methods

/*
 The data source methods are handled primarily by the fetch results controller
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger retval = 0;
    
    retval = 3;
    
    return retval;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger retval = 0;
    
    switch (section) {
        case 0:
            retval = 1;
            break;
        case 1:
            retval = 1 + [options count];
            break;
        case 2:
            retval = 1;
            break;
            
        default:
            break;
    }
    
    return retval;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    switch (indexPath.section) {
        case 0:
            cell = self.titleCell;
            break;
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                    cell = self.addOptionCell;
                    break;
                default:
                {
                    NSString *CellIdentifier = @"OptionCell";
                    
                    NSInteger optionIndex = indexPath.row - 1;
                    Option *option = [options objectAtIndex:optionIndex];
                    
                    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    if (cell == nil) {
                        [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
                        OptionCell *optionCell = (OptionCell*)self.tmpCell;
                        optionCell.textView.text = option.desc;
                        
                        cell = optionCell;
                        self.tmpCell = nil;
                    }
                }
                    break;
            }
        }
            break;
        case 2:
            cell = self.descCell;
            break;
        default:
            break;
    }
    
    return cell;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell to show the book's title
    Option *option = [options objectAtIndex:indexPath.row];
	cell.textLabel.text = option.desc;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    BOOL retval = NO;
    
    if (indexPath.section == 1 && indexPath.row > 1) {
        retval = YES;
    }
    
    return retval;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat retval = 80;
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            retval = 44;
        }
    }
    
    return retval;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *retval = nil;
    
	switch (section) {
        case 0:
            retval = @"问题";
            break;
        case 1:
            retval = @"选项";
            break;
        case 2:
            retval = @"其他描述";
            break;
            
        default:
            break;
    }
    
    return retval;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		// Delete the managed object.
        NSInteger optionIndex = indexPath.row - 1;
        Option *option = [options objectAtIndex:optionIndex];
        
		NSManagedObjectContext *context = self.question.managedObjectContext;
		[context deleteObject:[options objectAtIndex:indexPath.row]];
        [self.question removeOptionsObject:option];
		
		NSError *error;
		if (![context save:&error]) {
			// Update to handle the error appropriately.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
        
        [self.tableView beginUpdates];
        [options removeObject:option];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        
        [self.tableView endUpdates];
    }   
}


@end
