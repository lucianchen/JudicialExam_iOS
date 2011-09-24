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

@interface PaperScrollViewController : UIViewController{
    UIScrollView *pagingScrollView;
	NSMutableArray *visiblePages;
	NSMutableArray *recycledPages;
    
    NSInteger firstNeededIndex;
	NSInteger lastNeededIndex;
    
    PaperQuestionView *tmpQuestionView;
    PaperPageSelector *pageSelector;
}

@property(nonatomic, retain) IBOutlet UIScrollView *pagingScrollView;
@property(nonatomic, assign) IBOutlet PaperQuestionView *tmpQuestionView;
@property(nonatomic, assign) PaperPageSelector *pageSelector;


@end
