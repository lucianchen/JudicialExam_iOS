//
//  Answer.h
//  JudicialExam
//
//  Created by Chen Liang on 9/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Option, Paper, Question;

@interface Answer : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) Question * question;
@property (nonatomic, retain) NSSet* options;
@property (nonatomic, retain) Paper * paper;

@end
