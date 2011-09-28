//
//  Util.h
//  JudicialExam
//
//  Created by Chen Liang on 9/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Record.h"
#import "Types.h"

@interface Util : NSObject {
    
}

+ (NSManagedObjectContext*)managedObjectContext;
+ (Record*)lastRecord;
+ (ValueDistributionType)distributionTypeByYear:(NSInteger)year;
+ (QuestionType)questionTypeById:(NSInteger)questionId valueType:(ValueDistributionType)type;
+ (NSInteger)questionWeightById:(NSInteger)questionId valueType:(ValueDistributionType)type;
+ (NSRange)rangeOfQuestionsType:(QuestionType)questionType valueType:(ValueDistributionType)valType;

@end
