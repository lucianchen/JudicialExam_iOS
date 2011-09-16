//
//  Paper.m
//  JudicialExam
//
//  Created by Chen Liang on 9/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Paper.h"
#import "Question.h"


@implementation Paper
@dynamic id;
@dynamic questions;

- (void)addQuestionsObject:(Question *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"questions" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"questions"] addObject:value];
    [self didChangeValueForKey:@"questions" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeQuestionsObject:(Question *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"questions" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"questions"] removeObject:value];
    [self didChangeValueForKey:@"questions" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addQuestions:(NSSet *)value {    
    [self willChangeValueForKey:@"questions" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"questions"] unionSet:value];
    [self didChangeValueForKey:@"questions" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeQuestions:(NSSet *)value {
    [self willChangeValueForKey:@"questions" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"questions"] minusSet:value];
    [self didChangeValueForKey:@"questions" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
