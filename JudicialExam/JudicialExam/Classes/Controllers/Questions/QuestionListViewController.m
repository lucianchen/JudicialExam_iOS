//
//  QuestionListViewController.m
//  JudicialExam
//
//  Created by Chen Liang on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QuestionListViewController.h"
#import "QuestionEditViewController.h"
#import "Util.h"
#import "Constants.h"
#import "DataGenerationViewController.h"
#import "QuestionListCell.h"
#import <QuartzCore/QuartzCore.h>

#define kFetchListCacheName @"QuestionList"

@interface QuestionListViewController()

@property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

- (void)editList;
- (void)addQuestion;
- (void)addControllerContextDidSave:(NSNotification*)saveNotification;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation QuestionListViewController
@synthesize yearControl;
@synthesize paperTypeControl;
@synthesize questionTableView;
@synthesize fetchedResultsController;
@synthesize tmpCell;

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
    [fetchedResultsController release];
    
    [questionTableView release];
    [yearControl release];
    [paperTypeControl release];
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
    
    //self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
//                                              initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
//                                                                                           target:self 
//                                                                                           action:@selector(addQuestion)] autorelease];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemAction 
                                              target:self 
                                              action:@selector(generateData:)] autorelease];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.yearControl.selectedSegmentIndex = 1;
    self.paperTypeControl.selectedSegmentIndex = 1;
    
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}

- (void)viewDidUnload
{
    [self setQuestionTableView:nil];
    
    [fetchedResultsController release];
    fetchedResultsController = nil;
    
    [self setYearControl:nil];
    [self setPaperTypeControl:nil];

    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (NSManagedObjectContext*)managedObjectContext{
    return [Util managedObjectContext];
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
	// Create and configure a fetch request with the Book entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:EntityNameQuestion inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
    
    NSInteger selectedYear = self.yearControl.selectedSegmentIndex;
    NSInteger selectedPaper = self.paperTypeControl.selectedSegmentIndex;
    
    NSPredicate *predicate = nil;
    if (selectedYear > 0 && selectedPaper <= 0) {
        predicate = [NSPredicate predicateWithFormat:@"%K == %d", @"year", PaperYearStart + selectedYear - 1];
    }else if (selectedPaper > 0 && selectedYear <= 0) {
        predicate = [NSPredicate predicateWithFormat:@"%K == %d", @"paperType", selectedPaper];
    }else if (selectedYear > 0 && selectedPaper > 0) {
        predicate = [NSPredicate predicateWithFormat:@"%K == %d AND %K == %d", @"year", PaperYearStart + selectedYear - 1, @"paperType", selectedPaper];
    }
    
    if (predicate) {
        [fetchRequest setPredicate:predicate];
    }
    
    // Create the sort descriptors array.
    NSSortDescriptor *descriptorYear = [[NSSortDescriptor alloc] initWithKey:@"year" ascending:YES];
    NSSortDescriptor *descriptorPaper = [[NSSortDescriptor alloc] initWithKey:@"paperType" ascending:YES];
	NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"Id" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObjects:descriptorYear,descriptorPaper, descriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
    [descriptor release];
    [descriptorYear release];
    [descriptorPaper release];
	
	// Create and initialize the fetch results controller.
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	fetchedResultsController = aFetchedResultsController;
	fetchedResultsController.delegate = self;
	
	// Memory management.
	[fetchRequest release];
	
	return fetchedResultsController;
}    

#pragma mark - Util
- (void)addQuestion{
    QuestionEditViewController *controller = [[[QuestionEditViewController alloc] init] autorelease];
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
    
    controller.delegate = (NSObject<QuestionEditViewControllerDelegate>*)self;
    
	controller.question = (Question*)[NSEntityDescription insertNewObjectForEntityForName:EntityNameQuestion inManagedObjectContext:self.managedObjectContext];
    
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    controller.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:controller action:@selector(cancel)];
    
    [self presentModalViewController:navController animated:YES];
}

- (void)editList{
    
}

#pragma mark - QuestionEditViewControllerDelegate
- (void)didSubmitQuestion:(Question*)question{
    NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
    [dnc addObserver:self selector:@selector(addControllerContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.managedObjectContext];
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
    [dnc removeObserver:self name:NSManagedObjectContextDidSaveNotification object:self.managedObjectContext];
    
    [self.questionTableView reloadData];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didCancelSubmitting{
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)addControllerContextDidSave:(NSNotification*)saveNotification{
    NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
	[context mergeChangesFromContextDidSaveNotification:saveNotification];
}

#pragma mark -
#pragma mark Table view data source methods

/*
 The data source methods are handled primarily by the fetch results controller
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"QuestionListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"QuestionListCell" owner:self options:nil];
        cell = self.tmpCell;
        self.tmpCell = nil;
        
        cell.layer.shouldRasterize = YES;
        cell.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    }
    
    // Configure the cell.
	[self configureCell:cell atIndexPath:indexPath];
    return cell;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell to show the book's title
	Question *question = [fetchedResultsController objectAtIndexPath:indexPath];
	
    QuestionListCell *listCell = (QuestionListCell*)cell;
    listCell.questionText.text = question.title;
    listCell.yearLabel.text = [NSString stringWithFormat:@"%@", question.year];
    listCell.paperTypeLabel.text = [NSString stringWithFormat:@"卷%@", question.paperType];
    listCell.questionIdLabel.text = [NSString stringWithFormat:@"%@.", question.questionId];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// Display the authors' names as section headings.
    return [[[fetchedResultsController sections] objectAtIndex:section] name];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		// Delete the managed object.
		NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
		[context deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
		
		NSError *error;
		if (![context save:&error]) {
			// Update to handle the error appropriately.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
    }   
}


#pragma mark -
#pragma mark Selection and moving

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QuestionEditViewController *controller = [[[QuestionEditViewController alloc] init] autorelease];
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
    
    controller.delegate = (NSObject<QuestionEditViewControllerDelegate>*)self;
    
    Question *question = [fetchedResultsController objectAtIndexPath:indexPath];
	controller.question = question;
    
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:navController animated:YES];
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	[self.questionTableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	
	UITableView *tableView = self.questionTableView;
    
	switch(type) {
			
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			// Reloading the section inserts a new row and ensures that titles are updated appropriately.
			[tableView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	
	switch(type) {
			
		case NSFetchedResultsChangeInsert:
			[self.questionTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.questionTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
	[self.questionTableView endUpdates];
}

#pragma - mark Override
- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [self.questionTableView setEditing:editing animated:animated];
    
    [super setEditing:editing animated:animated];
}

- (IBAction)generateData:(id)sender {
    [fetchedResultsController release];
    fetchedResultsController = nil;
    [self.questionTableView reloadData];
    
    DataGenerationViewController *controller = [[[DataGenerationViewController alloc] init] autorelease];
    
    controller.delegate = (NSObject<DataGenerationViewControllerDelegate> *)self;
    
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
    
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentModalViewController:navController animated:YES];
}

- (IBAction)yearChanged:(id)sender {
    [NSFetchedResultsController deleteCacheWithName:kFetchListCacheName];
    [fetchedResultsController release];
    fetchedResultsController = nil;
    
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    
    if (error) {
        abort();
    }
    
    [self.questionTableView reloadData];
}

- (IBAction)paperTypeChanged:(id)sender {
    [NSFetchedResultsController deleteCacheWithName:kFetchListCacheName];
    [fetchedResultsController release];
    fetchedResultsController = nil;
    
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    
    if (error) {
        abort();
    }
    
    [self.questionTableView reloadData];
}

- (void)dataGenerationDone{
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    
    [self.fetchedResultsController performFetch:&error];
    
    [self.questionTableView reloadData];
    
    [self dismissModalViewControllerAnimated:YES];
}
@end
