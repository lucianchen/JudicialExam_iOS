//
//  PaperResult.m
//  JudicialExam
//
//  Created by Chen, Liang on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PaperResult.h"

@implementation PaperResult
@synthesize score;
@synthesize ratio;
@synthesize wrongAnswers;
@synthesize paper;

- (void)dealloc{
    [wrongAnswers release];
    
    [super dealloc];
}

@end
