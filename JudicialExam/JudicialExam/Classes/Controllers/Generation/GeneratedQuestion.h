//
//  GeneratedQuestion.h
//  JudicialExam
//
//  Created by Chen, Liang on 9/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeneratedQuestion : NSObject{
    NSString * analysis;
    NSNumber * Id;
    NSNumber * optionType;
    NSNumber * paperType;
    NSString * subjectiveAnswer;
    NSString * title;
    NSNumber * year;
    NSArray *answers;
    NSArray *options;
}

@property (nonatomic, retain) NSString * analysis;
@property (nonatomic, retain) NSNumber * Id;
@property (nonatomic, retain) NSNumber * optionType;
@property (nonatomic, retain) NSNumber * paperType;
@property (nonatomic, retain) NSString * subjectiveAnswer;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSArray *answers;
@property (nonatomic, retain) NSArray *options;

@end
