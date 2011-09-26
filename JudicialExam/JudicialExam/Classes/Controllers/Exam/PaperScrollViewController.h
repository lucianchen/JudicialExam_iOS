//
//  PaperScrollViewController.h
//  JudicialExam
//
//  Created by Chen, Liang on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaperQuestionView.h"
#import "PaperPageSelector.h"
#import "Paper.h"
#import "Record.h"

@interface PaperScrollViewController : UIViewController{
    UIScrollView *pagingScrollView;
	NSMutableArray *visiblePages;
	NSMutableArray *recycledPages;
    
    NSInteger firstNeededIndex;
	NSInteger lastNeededIndex;
    
    PaperQuestionView *tmpQuestionView;
    PaperPageSelector *pageSelector;
    Paper *paper;
    Record *record;
    
    UITableViewCell *tmpCell;
    NSMutableDictionary *optionDict;
}

@property(nonatomic, retain) IBOutlet UIScrollView *pagingScrollView;
@property(nonatomic, assign) IBOutlet PaperQuestionView *tmpQuestionView;
@property(nonatomic, assign) PaperPageSelector *pageSelector;
@property(nonatomic, assign) Paper *paper;
@property(nonatomic, assign) Record *record;
@property(nonatomic, assign) UITableViewCell *tmpCell;
@property(nonatomic, readonly) NSMutableDictionary *optionDict;

@end
