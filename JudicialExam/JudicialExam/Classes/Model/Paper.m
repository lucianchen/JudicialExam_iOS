//
//  Paper.m
//  JudicialExam
//
//  Created by Chen, Liang on 9/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Paper.h"
#import "Question.h"


@implementation Paper
@dynamic Id;
@dynamic isOriginal;
@dynamic paperType;
@dynamic year;
@dynamic distributionType;
@dynamic fullMark;
@dynamic questions;

- (NSArray*)sortedQuestions{
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"optionType" ascending:YES];
    NSArray *retval = [[self.questions allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    [descriptor release];
    
    return retval;
}

@end
