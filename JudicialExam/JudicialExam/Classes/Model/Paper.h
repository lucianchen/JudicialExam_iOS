//
//  Paper.h
//  JudicialExam
//
//  Created by Chen, Liang on 9/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Question;

@interface Paper : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * Id;
@property (nonatomic, retain) NSNumber * paperType;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSNumber * isOriginal;
@property (nonatomic, retain) NSSet *questions;
@property (nonatomic, readonly) NSArray *sortedQuestions;
@end

@interface Paper (CoreDataGeneratedAccessors)

- (void)addQuestionsObject:(Question *)value;
- (void)removeQuestionsObject:(Question *)value;
- (void)addQuestions:(NSSet *)values;
- (void)removeQuestions:(NSSet *)values;

@end
