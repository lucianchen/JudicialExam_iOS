//
//  Answer.h
//  JudicialExam
//
//  Created by Chen, Liang on 9/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Option, Paper, Question;

@interface Answer : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * correct;
@property (nonatomic, retain) NSNumber * Id;
@property (nonatomic, retain) NSSet *options;
@property (nonatomic, retain) Paper *paper;
@property (nonatomic, retain) Question *question;
@end

@interface Answer (CoreDataGeneratedAccessors)

- (void)addOptionsObject:(Option *)value;
- (void)removeOptionsObject:(Option *)value;
- (void)addOptions:(NSSet *)values;
- (void)removeOptions:(NSSet *)values;

@end
