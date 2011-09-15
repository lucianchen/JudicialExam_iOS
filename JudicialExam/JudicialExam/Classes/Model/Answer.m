//
//  Answer.m
//  JudicialExam
//
//  Created by Chen Liang on 9/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Answer.h"
#import "Option.h"
#import "Paper.h"
#import "Question.h"


@implementation Answer
@dynamic id;
@dynamic question;
@dynamic options;
@dynamic paper;


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



@end
