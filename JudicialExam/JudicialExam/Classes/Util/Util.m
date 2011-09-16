//
//  Util.m
//  JudicialExam
//
//  Created by Chen Liang on 9/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Util.h"
#import "JudicialExamAppDelegate.h"

@implementation Util

+ (NSManagedObjectContext*)managedObjectContext{
    JudicialExamAppDelegate *appDelegate = (JudicialExamAppDelegate*)[[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
}

@end
