//
//  ExamSummaryViewController.m
//  JudicialExam
//
//  Created by Chen, Liang on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ExamSummaryViewController.h"

#define kCellImage @"cell.png"
#define kCellImageSelected @"cell_selected.png"

#define kCellImageH @"right.png"
#define kCellImageHSelected @"wrong.png"

@implementation ExamSummaryViewController
@synthesize hintLabel;
@synthesize summaryTableView;
@synthesize sectionOneCell;
@synthesize sectionTwoCell;
@synthesize sectionThreeCell;
@synthesize highlightDict;
@synthesize delegate;
@synthesize historyMode;
@synthesize style;

- (void)dealloc{
    [summaryTableView release];
    
    [sectionOneCell release];
    [sectionTwoCell release];
    [sectionThreeCell release];

    [highlightDict release];
    [hintLabel release];
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
    
    [self.summaryTableView setBackgroundView:nil];
    //[self.summaryTableView setBackgroundView:[[[UIView alloc] init] autorelease]];
    //[self.summaryTableView setBackgroundColor:UIColor.clearColor];
}

- (void)viewDidUnload
{
    [self setSectionOneCell:nil];
    [self setSectionTwoCell:nil];
    [self setSectionThreeCell:nil];
    [self setHintLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.historyMode) {
        self.summaryTableView.tableHeaderView = nil;
    }else {
        self.hintLabel.text = @"红色项目是未完成的题目，点击其中一项到对应的题目页面";
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark -
#pragma mark Table view data source methods

/*
 The data source methods are handled primarily by the fetch results controller
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    UITableViewCell *cell = nil;
    NSInteger startNum = 0;
    NSInteger cellCount = 0;
    
    if (style == SummaryStyleOne) {
        switch (indexPath.section) {
            case 0:
                cell = self.sectionTwoCell;
                startNum = 0;
                cellCount = 30;
                break;
            case 1:
                cell = self.sectionOneCell;
                startNum = 30;
                cellCount = 50;
                break;
            case 2:
                cell = self.sectionThreeCell;
                startNum = 80;
                cellCount = 20;
                break;
                
            default:
                break;
        }
    }else {
        switch (indexPath.section) {
            case 0:
                cell = self.sectionOneCell;
                cellCount = 50;
                break;
            case 1:
                cell = self.sectionTwoCell;
                startNum = 50;
                cellCount = 30;
                break;
            case 2:
                cell = self.sectionThreeCell;
                startNum = 80;
                cellCount = 20;
                break;
                
            default:
                break;
        }
    }
    
    UIView *container = [cell viewWithTag:1];
    NSArray *itemsOfSection = [self.highlightDict objectForKey:[NSNumber numberWithInt:indexPath.section]];
    if (container && itemsOfSection) {
        NSArray *cells = container.subviews;
        for (NSInteger i = 0; i < cellCount; ++i) {
            UIButton *cellButton = (UIButton*)[cells objectAtIndex:i];
            
            cellButton.contentMode = UIViewContentModeScaleAspectFit;
            cellButton.imageView.contentMode = UIViewContentModeTopLeft;
            
            UIImage *image = [UIImage imageNamed:historyMode ? kCellImageH : kCellImage];
            UIImage *imageSelected = [UIImage imageNamed:historyMode ? kCellImageHSelected : kCellImageSelected];
            
            [cellButton setBackgroundImage:image forState:UIControlStateNormal];
            [cellButton setBackgroundImage:imageSelected forState:UIControlStateSelected];
            
            cellButton.tag = indexPath.section;
            NSNumber *number = [NSNumber numberWithInt:startNum + i + 1];
            
            BOOL shouldHighlight = NO;
            if (NSNotFound != [itemsOfSection indexOfObject:number]) {
                //current cell should be set highlighted
                shouldHighlight = YES;
            }
            
            cellButton.selected = shouldHighlight;
            [cellButton addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
            [cellButton setTitle:[NSString stringWithFormat:@"%@", number] forState:UIControlStateNormal];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat retval = 0;
    
    switch (indexPath.section) {
        case 0:
            retval = 240;
            break;
        case 1:
            retval = 150;
            break;
        case 2:
            retval = 110;
            break;
            
        default:
            break;
    }
    
    if (style == SummaryStyleOne) {
        switch (indexPath.section) {
            case 0:
                retval = 150;
                break;
            case 1:
                retval = 240;
                break;
            case 2:
                retval = 110;
                break;
                
            default:
                break;
        }
    }else {
        switch (indexPath.section) {
            case 0:
                retval = 240;
                break;
            case 1:
                retval = 150;
                break;
            case 2:
                retval = 110;
                break;
                
            default:
                break;
        }
    }
    
    return retval;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1024, 20)];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:16];
    label.backgroundColor = [UIColor clearColor];
    
    NSString *retval = nil;
    
    switch (section) {
        case 0:
            retval = @"单项选择题";
            break;
        case 1:
            retval = @"多项选择题";
            break;
        case 2:
            retval = @"不定项选择题";
            break;
            
        default:
            break;
    }
    
    label.text = retval;
    
    return label;
}


- (IBAction)cellSelected:(id)sender{
    NSArray *views = [[(UIButton*)sender superview] subviews];
    NSInteger index = [views indexOfObject:sender];
    
    NSInteger section = [(UIButton*)sender tag];
    NSInteger startNum = 0;
    
    if (style == SummaryStyleOne) {
        switch (section) {
            case 1:
                startNum = 30;
                break;
            case 2:
                startNum = 80;
                break;
            default:
                break;
        }
    }else {
        switch (section) {
            case 1:
                startNum = 50;
                break;
            case 2:
                startNum = 80;
                break;
            default:
                break;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(didSelectItemForPage:)]) {
        [self.delegate didSelectItemForPage:startNum + index + 1];
    }
}

@end
