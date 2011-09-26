//
//  PaperQuestionView.m
//  JudicialExam
//
//  Created by Chen, Liang on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PaperQuestionView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PaperQuestionView
@synthesize backView;
@synthesize index;
@synthesize tableView;
@synthesize questionTypeButton;
@synthesize questionTypeLabel;

- (void)awakeFromNib{
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (void)dealloc{
    [tableView release];
    
    [questionTypeButton release];
    [questionTypeLabel release];
    [backView release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    
}

@end
