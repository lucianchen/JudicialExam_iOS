//
//  Record.h
//  JudicialExam
//
//  Created by Chen Liang on 9/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Paper;

@interface Record : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) Paper * paper;

@end
