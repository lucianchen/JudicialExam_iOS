//
//  Types.h
//  Aekitas
//
//  Created by Chen, Liang on 9/20/11.
//  Copyright 2011 MicroStrategy. All rights reserved.
//

#ifndef Aekitas_Types_h
#define Aekitas_Types_h

typedef enum {
    QuestionTypeSingle = 0,
    QuestionTypeMulti,
    QuestionTypeUndefined
}QuestionType;

typedef enum {
    BookmarkTypeQuestion = 0,
    BookmarkTypeOther
}BookmarkType;

typedef enum {
    PaperTypeOne = 1,
    PaperTypeTwo,
    PaperTypeThree,
    PaperTypeFour
}PaperType;

typedef enum {
    ValueDistributionTypeOne = 1,
    ValueDistributionTypeTwo = 2
}ValueDistributionType;


#define ExamPaperTypeAll (0)
typedef NSInteger ExamPaperType;

#define ExamQuestionYearAll (0)
typedef NSInteger ExamQuestionYear;

typedef enum {
    ExamQuestionSourceTypeRandom = 0,
    ExamQuestionSourceTypeByYear
}ExamQuestionSourceType;

typedef struct {
    ExamPaperType paperType;
    ExamQuestionSourceType questionSource;
    BOOL includingUserQuestions;
    ExamQuestionYear year;
}ExamPreSettings;

#endif
