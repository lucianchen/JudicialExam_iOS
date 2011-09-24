//
//  GeneratedQuestion.m
//  JudicialExam
//
//  Created by Chen, Liang on 9/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GeneratedQuestion.h"

@implementation GeneratedQuestion
@synthesize analysis;
@synthesize Id;
@synthesize optionType;
@synthesize paperType;
@synthesize subjectiveAnswer;
@synthesize title;
@synthesize year;
@synthesize answers;
@synthesize options;

- (void)dealloc{
    [analysis release];
    [Id release];
    [optionType release];
    [paperType release];
    [subjectiveAnswer release];
    [title release];
    [year release];
    [answers release];
    [options release];
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

@end
