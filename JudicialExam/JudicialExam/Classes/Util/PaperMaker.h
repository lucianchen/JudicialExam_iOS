//
//  PaperMaker.h
//  JudicialExam
//
//  Created by Chen Liang on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Paper.h"

typedef enum {
    PaperTypeRandom = 0,
    PaperTypeByYear,
    PaperTypeByType
}PaperType;

typedef enum {
    QuestionTypeOne = 0,
    QuestionTypeTwo,
    QuestionTypeThree
}QuestionType;

@interface PaperMaker : NSObject {
    
}

- (Paper*)makePaper:(PaperType)paperType questionType:(QuestionType)questionType;

@end
