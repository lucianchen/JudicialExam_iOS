//
//  PaperPageSelector.h
//  JudicialExam
//
//  Created by Chen, Liang on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaperPageSelector : NSObject{
    NSInteger totalPage;
    NSInteger currentPage;
}

@property(nonatomic, assign) NSInteger totalPage;
@property(nonatomic, assign) NSInteger currentPage;

- (void)initPage:(NSInteger)page;
- (void)addPageObserver:(NSObject *)observer selector:(SEL)selector;
- (void)removePageObserver:(NSObject *)observer selector:(SEL)selector;

@end
