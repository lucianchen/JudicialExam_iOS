//
//  PaperResult.h
//  JudicialExam
//
//  Created by Chen, Liang on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Types.h"
#import "Paper.h"

@interface PaperResult : NSObject{
    NSInteger score;
    float ratio;
    NSMutableArray *wrongAnswers;
    Paper *paper;
}

@property(nonatomic, assign) NSInteger score;
@property(nonatomic, assign) float ratio;
@property(nonatomic, retain) NSMutableArray *wrongAnswers;
@property(nonatomic, assign) Paper *paper;

@end
