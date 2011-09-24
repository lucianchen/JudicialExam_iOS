//
//  PaperGenerator.m
//  JudicialExam
//
//  Created by Chen, Liang on 9/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PaperGenerator.h"
#import "Constants.h"
#import "Util.h"
#import "Types.h"

int randomSort(id obj1, id obj2, void *context ) {
    arc4random();
    return (random()%3 - 1);    
}

void shuffle(NSMutableArray* array) {
    // call custom sort function
    [array sortUsingFunction:randomSort context:nil];
}

@implementation PaperGenerator

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (Paper*)paperFromSettings:(ExamPreSettings)settings{
    Paper *retval = nil;
    
    NSManagedObjectContext *managedObjectContext = [Util managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    if (settings.year > 0 && settings.paperType > 0) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:EntityNamePaper 
                                                  inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"Id" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:descriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [descriptor release];
        
        NSPredicate *predicate = nil;
        predicate = [NSPredicate predicateWithFormat:@"%K == %d AND %K == %d", @"year", settings.year, @"paperType", settings.paperType];
        
        if (predicate) {
            [fetchRequest setPredicate:predicate];
        }
        
        NSArray *papers = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
        
        if ([papers count]) {
            retval = [papers objectAtIndex:0];
        }
    }else {
        NSEntityDescription *entity = [NSEntityDescription entityForName:EntityNameQuestion 
                                                  inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"Id" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:descriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [descriptor release];
        
        NSPredicate *predicate = nil;
        
        if (settings.paperType > 0) {
            predicate = [NSPredicate predicateWithFormat:@"%K == %d", @"paperType", settings.paperType];
        }else if (settings.year > 0) {
            predicate = [NSPredicate predicateWithFormat:@"%K == %d", @"year", settings.year];
        }else {
            predicate = [NSPredicate predicateWithFormat:@"%K == %d AND %K == %d", @"year", settings.year, @"paperType", settings.paperType];
        }
        
        if (predicate) {
            [fetchRequest setPredicate:predicate];
        }
        
        NSArray *allQuestions = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
        
        for (QuestionType type = QuestionTypeSingle; type <= QuestionTypeUndefined; ++type) {
            predicate = [NSPredicate predicateWithFormat:@"%K == %d", @"optionType", type];
            NSMutableArray *questions = [NSMutableArray arrayWithArray:[allQuestions filteredArrayUsingPredicate:predicate]];
            shuffle(questions);
            
            NSInteger count = 0;
            switch (type) {
                case QuestionTypeSingle:
                    count = 50;
                    break;
                case QuestionTypeMulti:
                    count = 30;
                    break;
                case QuestionTypeUndefined:
                    count = 20;
                    break;
                default:
                    break;
            }
            
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, count)];
            NSArray *chosenArray = [questions objectsAtIndexes:indexSet];
            NSSet *questionSet = [NSSet setWithArray:chosenArray];
            
            Paper *paper = (Paper*)[NSEntityDescription insertNewObjectForEntityForName:EntityNamePaper inManagedObjectContext:managedObjectContext];
            paper.paperType = [NSNumber numberWithInt:settings.paperType];
            paper.isOriginal = [NSNumber numberWithBool:NO];
            [paper addQuestions:questionSet];
            
            retval = paper;
        } 
    }
    
    [fetchRequest release];
    return retval;
}

@end
