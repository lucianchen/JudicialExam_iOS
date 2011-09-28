//
//  Record.h
//  JudicialExam
//
//  Created by Chen, Liang on 9/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Answer, Paper;

@interface Record : NSManagedObject {
@private
}
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * Id;
@property (nonatomic, retain) NSNumber * completed;
@property (nonatomic, retain) NSNumber * leftTime;
@property (nonatomic, retain) NSNumber * lastPage;
@property (nonatomic, retain) NSSet *answers;
@property (nonatomic, retain) Paper *paper;
@end

@interface Record (CoreDataGeneratedAccessors)

- (void)addAnswersObject:(Answer *)value;
- (void)removeAnswersObject:(Answer *)value;
- (void)addAnswers:(NSSet *)values;
- (void)removeAnswers:(NSSet *)values;

@end
