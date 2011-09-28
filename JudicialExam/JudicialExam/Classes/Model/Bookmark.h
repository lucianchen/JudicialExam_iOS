//
//  Bookmark.h
//  JudicialExam
//
//  Created by Chen, Liang on 9/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Bookmark : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * addDate;
@property (nonatomic, retain) NSNumber * itemId;
@property (nonatomic, retain) NSNumber * itemType;

@end
