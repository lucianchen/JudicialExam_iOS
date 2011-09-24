//
//  QuestionListCell.m
//  JudicialExam
//
//  Created by Chen, Liang on 9/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QuestionListCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation QuestionListCell
@synthesize questionText;
@synthesize paperTypeLabel;
@synthesize yearLabel;
@synthesize questionIdLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib{
    CALayer *layer = self.questionText.layer;
    layer.masksToBounds = YES;
    layer.borderColor = [[UIColor grayColor] CGColor];
    layer.borderWidth = 1;
    layer.cornerRadius = 10;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [questionText release];
    [yearLabel release];
    [paperTypeLabel release];
    [questionIdLabel release];
    [super dealloc];
}
@end
