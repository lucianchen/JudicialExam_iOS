//
//  DataGenerator.m
//  JudicialExam
//
//  Created by Chen, Liang on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataGenerator.h"
#import "Types.h"
#import "Util.h"
#import "Question.h"
#import "Option.h"
#import "Paper.h"

#import "Constants.h"
#import "GeneratedQuestion.h"
#import "JudicialExamAppDelegate.h"

@interface DataGenerator()

- (void)generateDataForYear:(NSInteger)year paperType:(PaperType)paperType;
- (NSArray*)optionIndexesFromString:(NSString*)string;

- (GeneratedQuestion*)questionEntityFromString:(NSString*)string year:(NSInteger)year paperType:(PaperType)paperType questionId:(NSInteger)questionId;
- (QuestionType)questionTypeFromQuestionId:(NSInteger)questionId year:(NSInteger)year;
- (void)notifyProgress:(NSInteger)year questionId:(NSInteger)questionId paperType:(PaperType)paperType;

@end

@implementation DataGenerator
@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (NSArray*)missedList{
    return missedList;
}

- (NSInteger)count{
    return count;
}

- (void)startGeneration{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        JudicialExamAppDelegate *appDelegate = (JudicialExamAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        [appDelegate reCreateStore];
        
        missedList = [[NSMutableArray alloc] init];
        count = 0;
        
        for (NSInteger year = 2002; year <= 2010; year++) {
            for (NSInteger paperType = PaperTypeOne; paperType < PaperTypeFour; paperType++) {
                [self notifyProgress:year questionId:0 paperType:paperType];
                [self generateDataForYear:year paperType:paperType];
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(dataGenerationDone:)]) {
            [self.delegate dataGenerationDone:YES];
        }
        
        [missedList release];
        missedList = nil;
    });
}

- (void)generateDataForYear:(NSInteger)year paperType:(PaperType)paperType{
    NSString *paperFileName = [NSString stringWithFormat:@"%d-%d", year, paperType];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:paperFileName ofType:@"txt"];
    
    NSManagedObjectContext *managedObjectContext = [Util managedObjectContext];
    
    Paper *paper = (Paper*)[NSEntityDescription insertNewObjectForEntityForName:EntityNamePaper inManagedObjectContext:managedObjectContext];
    paper.paperType = [NSNumber numberWithInt:paperType];
    paper.year = [NSNumber numberWithInt:year];
    paper.isOriginal = [NSNumber numberWithBool:YES];
    
    ValueDistributionType distributionType = (year >= 2004) ? ValueDistributionTypeTwo : ValueDistributionTypeOne;
    paper.distributionType = [NSNumber numberWithInt:distributionType];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSString *paperString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        
        for (NSInteger questionId = 1; questionId <= 100; ++questionId) {
            NSRange range = [paperString rangeOfString:[NSString stringWithFormat:@"%d.", questionId]
                                               options:NSWidthInsensitiveSearch | NSCaseInsensitiveSearch];
            
            
            if (range.location != NSNotFound) {
                NSString *string = nil;
                if (questionId == 100) {
                    string = [paperString substringFromIndex:range.location];
                    count++;
                }else {
                    NSRange nextRange = [paperString rangeOfString:[NSString stringWithFormat:@"%d.", questionId + 1]
                                                           options:NSWidthInsensitiveSearch | NSCaseInsensitiveSearch
                                                             range:NSMakeRange(range.location, [paperString length] - range.location)
                                         ];
                    
                    if (nextRange.location != NSNotFound) {
                        string = [paperString substringWithRange:
                                  NSMakeRange(range.location, nextRange.location - range.location)
                                  ];
                        count++;
                    }else {
                        NSString *missedQuestionDesc = [NSString stringWithFormat:@"%d-卷%d-%d\n", year, paperType, questionId];
                        [missedList addObject:missedQuestionDesc];
                        continue;
                    }
                }
                
                GeneratedQuestion *entityQuestion = [self questionEntityFromString:string year:year paperType:paperType questionId:questionId];
                
                
                Question *question = (Question*)[NSEntityDescription insertNewObjectForEntityForName:EntityNameQuestion inManagedObjectContext:managedObjectContext];
                
                question.title = entityQuestion.title;
                question.analysis = entityQuestion.analysis;
                question.year = [NSNumber numberWithInt:year];
                question.questionId = [NSNumber numberWithInt:questionId];
                question.paperType = [NSNumber numberWithInt:paperType];
                
                NSInteger idNumber = 100000 * year + 1000 * paperType + questionId;
                question.Id = [NSNumber numberWithInt:idNumber];
                
                question.optionType = [NSNumber numberWithInt:
                                       [self questionTypeFromQuestionId:questionId year:year]
                                       ];
                
                for (int i = 0; i < 4; ++i) {
                    Option *option = (Option*)[NSEntityDescription insertNewObjectForEntityForName:EntityNameOption inManagedObjectContext:managedObjectContext];
                    option.desc = [entityQuestion.options objectAtIndex:i];
                    
                    [question addOptionsObject:option];
                    
                    if (NSNotFound != [entityQuestion.answers indexOfObject:[NSNumber numberWithInt:i]]) {
                        [question addAnswersObject:option];
                    }
                    
                    sleep(0.01);
                }
                
                [paper addQuestionsObject:question];
                
//                NSError *error = nil;
//                if (![managedObjectContext save:&error]) {
//                    // Update to handle the error appropriately.
//                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//                    NSArray *errors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
//                    abort();
//                }
            }
            else {
                NSString *missedQuestionDesc = [NSString stringWithFormat:@"%d-卷%d-%d\n", year, paperType, questionId];
                [missedList addObject:missedQuestionDesc];
            }
        }
    
        NSSet *questionsInserted = paper.questions;
        NSLog(@"Paper of year:%d created, type: %d, num:%d", year, paperType, [questionsInserted count]);
        
    }
    
}

- (QuestionType)questionTypeFromQuestionId:(NSInteger)questionId year:(NSInteger)year{
    QuestionType type = QuestionTypeSingle;
    
    if (year < 2004) {
        if (questionId <= 30) {
            
        }else if (questionId > 30 && questionId < 80) {
            type = QuestionTypeMulti;
        }else {
            type = QuestionTypeUndefined;
        }
    }else {
        if (questionId <= 30) {
            
        }else if (questionId > 50 && questionId < 80) {
            type = QuestionTypeMulti;
        }else {
            type = QuestionTypeUndefined;
        }
    }
    
    return type;
}

- (void)notifyProgress:(NSInteger)year questionId:(NSInteger)questionId paperType:(PaperType)paperType{
    NSInteger years = 2010 - 2002 + 1;
    CGFloat percentage = (float)(year - 2002) / (float)(years);
    percentage += (float)(questionId + paperType * 100) / (100.0 * 3 * years);
    
    NSString *status = [NSString stringWithFormat:@"添加题目:卷%d-%d年", paperType, year];
    
    if ([self.delegate respondsToSelector:@selector(statusDidUpdate:message:)]) {
        [self.delegate statusDidUpdate:percentage message:status];
    }
}

- (GeneratedQuestion*)questionEntityFromString:(NSString*)string year:(NSInteger)year paperType:(PaperType)paperType questionId:(NSInteger)questionId{
    GeneratedQuestion *retval = [[[GeneratedQuestion alloc] init] autorelease];
    
    //now we got the question string
    NSRange optionRangeA = [string rangeOfString:@"A." options:NSWidthInsensitiveSearch | NSCaseInsensitiveSearch];
    NSRange optionRangeB = [string rangeOfString:@"B." options:NSWidthInsensitiveSearch | NSCaseInsensitiveSearch];
    NSRange optionRangeC = [string rangeOfString:@"C." options:NSWidthInsensitiveSearch | NSCaseInsensitiveSearch];
    NSRange optionRangeD = [string rangeOfString:@"D." options:NSWidthInsensitiveSearch | NSCaseInsensitiveSearch];
    
    if (optionRangeA.location == NSNotFound ||
        optionRangeB.location == NSNotFound ||
        optionRangeC.location == NSNotFound ||
        optionRangeD.location == NSNotFound
        ) {
        NSLog(@"Some components not found. Year: %d, paper type: %d, question id:%d", year, paperType, questionId);
        abort();
    }
    
    NSString *questionTitle = [string substringToIndex:optionRangeA.location];
    NSString *optionStringA = [string substringWithRange:
                               NSMakeRange(optionRangeA.location, optionRangeB.location - optionRangeA.location)];
    NSString *optionStringB = [string substringWithRange:
                               NSMakeRange(optionRangeB.location, optionRangeC.location - optionRangeB.location)];
    NSString *optionStringC = [string substringWithRange:
                               NSMakeRange(optionRangeC.location, optionRangeD.location - optionRangeC.location)];
    NSString *optionStringD = nil;
    NSString *analysisString = nil;
    NSString *answerString = nil;
    
    switch (year) {
        case 2002:
        {
            NSString *answerPrefix = @"【答案】：";
            NSString *analysisPrefix = @"【解析】：";
            
            NSRange analysisRange = [string rangeOfString:analysisPrefix options:NSWidthInsensitiveSearch | NSCaseInsensitiveSearch];
            NSRange answerRange = [string rangeOfString:answerPrefix options:NSWidthInsensitiveSearch | NSCaseInsensitiveSearch];
            
            if (analysisRange.location == NSNotFound ||
                answerRange.location == NSNotFound
                ) {
                abort();
            }
            
            optionStringD = [string substringWithRange:
                             NSMakeRange(optionRangeD.location, analysisRange.location - optionRangeD.location)];
            analysisString = [string substringWithRange:
                              NSMakeRange(analysisRange.location, answerRange.location - analysisRange.location)];
            answerString = [string substringFromIndex:answerRange.location];
            
            analysisString = [analysisString substringFromIndex:[analysisPrefix length]];
            answerString = [answerString substringFromIndex:[answerPrefix length]];
        }
            break;
            
        case 2003:
        case 2007:
        case 2008:
        case 2009:
        {
            NSString *answerPrefix = nil;
            NSString *analysisPrefix = nil;
            
            if (year == 2003) {
                answerPrefix = @"【答 案】";
                analysisPrefix = @"【解析】";
            }else {
                answerPrefix = @"答案：";
                analysisPrefix = @"解析：";
            }
            
            NSRange analysisRange = [string rangeOfString:analysisPrefix options:NSWidthInsensitiveSearch];
            NSRange answerRange = [string rangeOfString:answerPrefix options:NSWidthInsensitiveSearch | NSCaseInsensitiveSearch];
            
            if (analysisRange.location == NSNotFound ||
                answerRange.location == NSNotFound
                ) {
                abort();
            }
            
            optionStringD = [string substringWithRange:
                             NSMakeRange(optionRangeD.location, answerRange.location - optionRangeD.location)];
            
            answerString = [string substringWithRange:
                              NSMakeRange(answerRange.location, analysisRange.location - answerRange.location)];
            
            analysisString = [string substringFromIndex:analysisRange.location];
            
            analysisString = [analysisString substringFromIndex:[analysisPrefix length]];
            answerString = [answerString substringFromIndex:[answerPrefix length]];
        }
            break;
        
        case 2004:
        {
            NSString *answerPrefix = @"【答案及解析】：";

            NSRange answerRange = [string rangeOfString:answerPrefix options:NSWidthInsensitiveSearch | NSCaseInsensitiveSearch];
            
            if (answerRange.location == NSNotFound) {
                abort();
            }
            
            optionStringD = [string substringWithRange:
                             NSMakeRange(optionRangeD.location, answerRange.location - optionRangeD.location)];
            
            answerString = [string substringFromIndex:(answerRange.location + [answerPrefix length])];
            
            NSMutableString *answer = [NSMutableString string];
            NSInteger i = 0;
            for (; i < 4; ++i) {
                unichar character = [answerString characterAtIndex:i];
                
                if (character >= 'A' && character <= 'D') {
                    [answer appendString:[NSString stringWithCharacters:&character length:1]];
                }else {
                    break;
                }
            }
            
            analysisString = [answerString substringFromIndex:i];
            answerString = [answerString substringToIndex:i];    
        }
            break;
        case 2005:
        {
            NSString *answerPrefix = @"【答案】";
            NSString *analysisPrefix = @"【考点】";
            
            NSRange analysisRange = [string rangeOfString:analysisPrefix options:NSWidthInsensitiveSearch | NSCaseInsensitiveSearch];
            NSRange answerRange = [string rangeOfString:answerPrefix options:NSWidthInsensitiveSearch | NSCaseInsensitiveSearch];
            
            if (analysisRange.location == NSNotFound ||
                answerRange.location == NSNotFound
                ) {
                abort();
            }
            
            optionStringD = [string substringWithRange:
                             NSMakeRange(optionRangeD.location, analysisRange.location - optionRangeD.location)];
            analysisString = [string substringWithRange:
                              NSMakeRange(analysisRange.location, answerRange.location - analysisRange.location)];
            answerString = [string substringFromIndex:answerRange.location];
            
            //analysisString = [analysisString substringFromIndex:[kPrefixAnalysis length]];
            answerString = [answerString substringFromIndex:[answerPrefix length]];
        }
            break;
        case 2006:
        {
            NSString *answerPrefix = @"【答案】";
            NSString *analysisPrefix = @"【考点】";
            
            NSRange analysisRange = [string rangeOfString:analysisPrefix options:NSWidthInsensitiveSearch | NSCaseInsensitiveSearch];
            NSRange answerRange = [string rangeOfString:answerPrefix options:NSWidthInsensitiveSearch | NSCaseInsensitiveSearch];
            
            if (analysisRange.location == NSNotFound ||
                answerRange.location == NSNotFound
                ) {
                abort();
            }
            
            optionStringD = [string substringWithRange:
                             NSMakeRange(optionRangeD.location, answerRange.location - optionRangeD.location)];
            
            answerString = [string substringWithRange:
                            NSMakeRange(answerRange.location, analysisRange.location - answerRange.location)];
            
            analysisString = [string substringFromIndex:analysisRange.location];
            
//            analysisString = [analysisString substringFromIndex:[analysisPrefix length]];
            answerString = [answerString substringFromIndex:[answerPrefix length]];
        }
            break;
        case 2010:
        {
            NSString *answerPrefix = @"【万国答案】";
            NSString *standardAnswerPrefix = @"【司法部答案】";
            NSString *analysisPointPrefix = @"【考点】";
            NSString *analysisPrefix = @"【解析】";
            
            NSRange analysisRange = [string rangeOfString:analysisPrefix options:NSWidthInsensitiveSearch | NSCaseInsensitiveSearch];
            NSRange answerRange = [string rangeOfString:answerPrefix options:NSWidthInsensitiveSearch | NSCaseInsensitiveSearch];
            NSRange analysisPointAnalysisRange = [string rangeOfString:analysisPointPrefix options:NSWidthInsensitiveSearch | NSCaseInsensitiveSearch];
            NSRange standardAnswerRange = [string rangeOfString:standardAnswerPrefix options:NSWidthInsensitiveSearch | NSCaseInsensitiveSearch];
            
            if (analysisRange.location == NSNotFound ||
                answerRange.location == NSNotFound ||
                analysisPointAnalysisRange.location == NSNotFound ||
                standardAnswerRange.location == NSNotFound
                ) {
                abort();
            }
            
            NSString *analysisPointString = nil;
            
            optionStringD = [string substringWithRange:
                             NSMakeRange(optionRangeD.location, analysisPointAnalysisRange.location - optionRangeD.location)];
            
            analysisPointString = [string substringWithRange:
                                   NSMakeRange(analysisPointAnalysisRange.location, standardAnswerRange.location - analysisPointAnalysisRange.location)];
            
            answerString = [string substringWithRange:
                            NSMakeRange(answerRange.location, analysisRange.location - answerRange.location)];
            
            analysisString = [string substringFromIndex:analysisRange.location];
            analysisString = [analysisString substringFromIndex:[analysisPrefix length]];
            analysisString = [NSString stringWithFormat:@"%@\n%@",
                              analysisPointString, analysisString
                              ];
            
            
            answerString = [answerString substringFromIndex:[answerPrefix length]];
        }
            break;
        default:
            break;
    }
    
    NSArray *answersIndexes = [self optionIndexesFromString:answerString];
    
    retval.answers = answersIndexes;
    
    optionStringA = [optionStringA substringFromIndex:2];
    optionStringB = [optionStringB substringFromIndex:2];
    optionStringC = [optionStringC substringFromIndex:2];
    optionStringD = [optionStringD substringFromIndex:2];
    
    optionStringA = [optionStringA stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    optionStringB = [optionStringB stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    optionStringC = [optionStringC stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    optionStringD = [optionStringD stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    retval.options = [NSArray arrayWithObjects:optionStringA, optionStringB, optionStringC, optionStringD, nil];
    
    NSString *titlePrefix = [NSString stringWithFormat:@"%d.", questionId];
    NSRange titlePrefixRange = [questionTitle rangeOfString:titlePrefix options:NSWidthInsensitiveSearch];
    if (titlePrefixRange.location != NSNotFound) {
        questionTitle = [questionTitle substringFromIndex:titlePrefixRange.length];
    }
    
    retval.title = [questionTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    retval.analysis = [analysisString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return retval;
}

- (NSArray*)optionIndexesFromString:(NSString*)string{
    NSMutableArray *retval = [NSMutableArray array];
    
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    for (NSInteger i = 0; i < [string length]; ++i) {
        unichar character = [string characterAtIndex:i];
        switch (character) {
            case 'A':
                [retval addObject:[NSNumber numberWithInt:0]];
                break;
            case 'B':
                [retval addObject:[NSNumber numberWithInt:1]];
                break;
            case 'C':
                [retval addObject:[NSNumber numberWithInt:2]];
                break;
            case 'D':
                [retval addObject:[NSNumber numberWithInt:3]];
                break;
                
            default:
                break;
        }
    }
    
    return retval;
}

@end
