//
//  Question.m
//  JudicialExam
//
//  Created by Chen Liang on 9/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Question.h"
#import "Option.h"


@implementation Question
@dynamic id;
@dynamic title;
@dynamic year;
@dynamic type;
@dynamic analysis;
@dynamic options;
@dynamic answer;

- (void)addOptionsObject:(Option *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"options" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"options"] addObject:value];
    [self didChangeValueForKey:@"options" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeOptionsObject:(Option *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"options" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"options"] removeObject:value];
    [self didChangeValueForKey:@"options" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addOptions:(NSSet *)value {    
    [self willChangeValueForKey:@"options" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"options"] unionSet:value];
    [self didChangeValueForKey:@"options" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeOptions:(NSSet *)value {
    [self willChangeValueForKey:@"options" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"options"] minusSet:value];
    [self didChangeValueForKey:@"options" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


- (void)addAnswerObject:(Option *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"answer" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"answer"] addObject:value];
    [self didChangeValueForKey:@"answer" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeAnswerObject:(Option *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"answer" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"answer"] removeObject:value];
    [self didChangeValueForKey:@"answer" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addAnswer:(NSSet *)value {    
    [self willChangeValueForKey:@"answer" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"answer"] unionSet:value];
    [self didChangeValueForKey:@"answer" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeAnswer:(NSSet *)value {
    [self willChangeValueForKey:@"answer" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"answer"] minusSet:value];
    [self didChangeValueForKey:@"answer" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
