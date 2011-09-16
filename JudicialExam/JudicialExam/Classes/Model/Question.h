//
//  Question.h
//  JudicialExam
//
//  Created by Chen Liang on 9/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Option;

@interface Question : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * optionType;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * analysis;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSSet* options;

@end
