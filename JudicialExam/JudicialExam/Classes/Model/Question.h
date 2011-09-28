//
//  Question.h
//  JudicialExam
//
//  Created by Chen, Liang on 9/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Option;

@interface Question : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * analysis;
@property (nonatomic, retain) NSNumber * Id;
@property (nonatomic, retain) NSNumber * optionType;
@property (nonatomic, retain) NSNumber * paperType;
@property (nonatomic, retain) NSString * subjectiveAnswer;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSNumber * questionId;
@property (nonatomic, retain) NSSet *answers;
@property (nonatomic, retain) NSSet *options;
@end

@interface Question (CoreDataGeneratedAccessors)

- (void)addAnswersObject:(Option *)value;
- (void)removeAnswersObject:(Option *)value;
- (void)addAnswers:(NSSet *)values;
- (void)removeAnswers:(NSSet *)values;

- (void)addOptionsObject:(Option *)value;
- (void)removeOptionsObject:(Option *)value;
- (void)addOptions:(NSSet *)values;
- (void)removeOptions:(NSSet *)values;

@end
