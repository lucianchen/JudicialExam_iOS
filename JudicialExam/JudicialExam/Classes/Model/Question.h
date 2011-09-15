//
//  Question.h
//  JudicialExam
//
//  Created by Chen Liang on 9/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Option;

@interface Question : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * analysis;
@property (nonatomic, retain) NSSet* options;
@property (nonatomic, retain) NSSet* answer;

@end
