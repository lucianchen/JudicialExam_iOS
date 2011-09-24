//
//  Option.h
//  JudicialExam
//
//  Created by Chen, Liang on 9/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Option : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * Id;

@end
