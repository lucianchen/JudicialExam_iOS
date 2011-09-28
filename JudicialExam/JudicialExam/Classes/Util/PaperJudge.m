//
//  PaperJudge.m
//  JudicialExam
//
//  Created by Chen, Liang on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PaperJudge.h"
#import "Paper.h"
#import "Option.h"
#import "Answer.h"
#import "Question.h"
#import "Util.h"

@implementation PaperJudge

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (PaperResult*)judge:(Record*)record{
    PaperResult *result = [[[PaperResult alloc] init] autorelease];
    Paper *paper = record.paper;
    NSInteger questionNum = [record.paper.questions count];
    NSInteger correctNum = 0;
    
    //NSInteger fullMark = [record.paper.fullMark intValue];
    NSInteger score = 0;
    
    NSMutableArray *wrongAnswers = [NSMutableArray array];
    ValueDistributionType distributionType = [record.paper.distributionType intValue];
    
    for (Answer *answer in record.answers) {
        NSSet *options = answer.options;
        NSSet *standardAnswer = [answer.question answers];
        
        if ([options isEqualToSet:standardAnswer]) {
            correctNum++;
            
            NSInteger weight = [Util questionWeightById:[answer.Id intValue] valueType:distributionType];
            score += weight;
        }else {
            [wrongAnswers addObject:answer.Id];
        }
    }
    
    result.score = score;
    result.ratio = (float)correctNum / (float)(questionNum);
    result.paper = paper;
    
    result.wrongAnswers = wrongAnswers;
    
    return result;
}

@end
