//
//  Util.m
//  JudicialExam
//
//  Created by Chen Liang on 9/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Util.h"
#import "JudicialExamAppDelegate.h"
#import "Constants.h"

@implementation Util

+ (NSManagedObjectContext*)managedObjectContext{
    JudicialExamAppDelegate *appDelegate = (JudicialExamAppDelegate*)[[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
}

+ (Record*)lastRecord{
    NSEntityDescription *entity = [NSEntityDescription entityForName:EntityNameRecord 
                                              inManagedObjectContext:[Util managedObjectContext]];
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:descriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [descriptor release];
    
    NSArray *allRecords = [[Util managedObjectContext] executeFetchRequest:fetchRequest error:nil];
    
    Record *lastRecord = nil;
    if ([allRecords count]) {
        lastRecord = [allRecords objectAtIndex:0];
    }
    
    return lastRecord;
}

+ (ValueDistributionType)distributionTypeByYear:(NSInteger)year{
    ValueDistributionType retval = ValueDistributionTypeOne;
    
    if (year >= 2004) {
        retval = ValueDistributionTypeTwo;
    }
    
    return retval;
}

+ (QuestionType)questionTypeById:(NSInteger)questionId valueType:(ValueDistributionType)type{
    QuestionType retval = QuestionTypeSingle;
    
    switch (type) {
        case ValueDistributionTypeOne:
        {
            if (questionId <= 30) {
                retval = QuestionTypeSingle;
            }else if (questionId <= 80) {
                retval = QuestionTypeMulti;
            }else {
                retval = QuestionTypeUndefined;
            }
        }
            break;
        case ValueDistributionTypeTwo:
        {
            if (questionId <= 50) {
                retval = QuestionTypeSingle;
            }else if (questionId <= 80) {
                retval = QuestionTypeMulti;
            }else {
                retval = QuestionTypeUndefined;
            }
        }
            break;
        default:
            break;
    }
    
    return retval;
}

+ (NSInteger)questionWeightById:(NSInteger)questionId valueType:(ValueDistributionType)type{
    NSInteger retval = 0;
    
    switch (type) {
        case ValueDistributionTypeOne:
        {
            retval = 1;
        }
            break;
        case ValueDistributionTypeTwo:
        {
            if (questionId <= 50) {
                retval = 1;
            }else if (questionId <= 80) {
                retval = 2;
            }else {
                retval = 2;
            }
        }
            break;
        default:
            break;
    }
    
    return retval;
}

+ (NSRange)rangeOfQuestionsType:(QuestionType)questionType valueType:(ValueDistributionType)valType{
    NSRange retval;
    
    switch (valType) {
        case ValueDistributionTypeOne:
        {
            switch (questionType) {
                case QuestionTypeSingle:
                    retval = NSMakeRange(0, 30);
                    break;
                case QuestionTypeMulti:
                    retval = NSMakeRange(30, 50);
                    break;
                case QuestionTypeUndefined:
                    retval = NSMakeRange(80, 20);
                    break;
                default:
                    break;
            }
        }
            break;
        case ValueDistributionTypeTwo:
        {
            switch (questionType) {
                case QuestionTypeSingle:
                    retval = NSMakeRange(0, 50);
                    break;
                case QuestionTypeMulti:
                    retval = NSMakeRange(50, 30);
                    break;
                case QuestionTypeUndefined:
                    retval = NSMakeRange(80, 20);
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    
    return retval;
}

@end
