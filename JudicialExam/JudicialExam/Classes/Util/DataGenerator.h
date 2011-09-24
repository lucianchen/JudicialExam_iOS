//
//  DataGenerator.h
//  JudicialExam
//
//  Created by Chen, Liang on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DataGeneratorDelegate <NSObject>

- (void)statusDidUpdate:(float)percentage message:(NSString*)message;
- (void)dataGenerationDone:(BOOL)succeeded;

@end

@interface DataGenerator : NSObject{
    NSObject<DataGeneratorDelegate> *delegate;
    NSMutableArray *missedList;
    NSInteger count;
}

@property(nonatomic, assign) NSObject<DataGeneratorDelegate> *delegate;
@property(nonatomic, readonly) NSArray *missedList;
@property(nonatomic, readonly) NSInteger count;

- (void)startGeneration;

@end
