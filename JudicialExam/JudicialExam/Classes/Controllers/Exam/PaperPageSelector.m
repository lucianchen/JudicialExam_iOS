//
//  PaperPageSelector.m
//  JudicialExam
//
//  Created by Chen, Liang on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PaperPageSelector.h"
#import "Constants.h"

@implementation PaperPageSelector
@synthesize totalPage;
@synthesize currentPage;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)initPage:(NSInteger)page{
    currentPage = page;
}

- (void)setCurrentPage:(NSInteger)page{
    BOOL shouldNotify = NO;
    
    if (currentPage != page) {
        shouldNotify = YES;
    }
    
    if (shouldNotify) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationPageChanged object:nil];
    }
}

- (void)addPageObserver:(NSObject *)observer selector:(SEL)selector{
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:NotificationPageChanged object:self];
}

- (void)removePageObserver:(NSObject *)observer selector:(SEL)selector{
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:NotificationPageChanged object:self];
}

@end
