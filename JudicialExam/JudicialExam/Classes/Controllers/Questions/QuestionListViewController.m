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

@interface QuestionListViewController()

@property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObjectContext *addingManagedObjectContext;

- (void)editList;
- (void)addQuestion;
- (void)addControllerContextDidSave:(NSNotification*)saveNotification;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation QuestionListViewController
@synthesize questionTableView;
@synthesize fetchedResultsController;
@synthesize addingManagedObjectContext;

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
    [addingManagedObjectContext release];
    
    [questionTableView release];
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
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                                                                           target:self 
                                                                                           action:@selector(addQuestion)] autorelease];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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
    
    // Create the sort descriptors array.
	NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObjects:descriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
    [descriptor release];
	
	// Create and initialize the fetch results controller.
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"QuestionList"];
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
    
    NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] init];
	self.addingManagedObjectContext = addingContext;
	[addingContext release];
	
	[addingManagedObjectContext setPersistentStoreCoordinator:[[self.fetchedResultsController managedObjectContext] persistentStoreCoordinator]];
    
	controller.question = (Question*)[NSEntityDescription insertNewObjectForEntityForName:EntityNameQuestion inManagedObjectContext:addingContext];
    
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:navController animated:YES];
}

- (void)editList{
    
}

#pragma mark - QuestionEditViewControllerDelegate
- (void)didSubmitQuestion:(Question*)question{
    NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
    [dnc addObserver:self selector:@selector(addControllerContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:addingManagedObjectContext];
    
    NSError *error;
    if (![addingManagedObjectContext save:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
    [dnc removeObserver:self name:NSManagedObjectContextDidSaveNotification object:addingManagedObjectContext];
    
	self.addingManagedObjectContext = nil;
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didCancelSubmitting{
    
    self.addingManagedObjectContext = nil;
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
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell.
	[self configureCell:cell atIndexPath:indexPath];
    return cell;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell to show the book's title
	Question *question = [fetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = question.title;
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
	
//    // Create and push a detail view controller.
//	DetailViewController *detailViewController = [[DetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
//    Book *selectedBook = (Book *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
//    // Pass the selected book to the new view controller.
//    detailViewController.book = selectedBook;
//	[self.navigationController pushViewController:detailViewController animated:YES];
//	[detailViewController release];
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

@end
