//
//  PaperJudge.h
//  JudicialExam
//
//  Created by Chen, Liang on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Record.h"
#import "PaperResult.h"

@interface PaperJudge : NSObject{
    
}

+ (PaperResult*)judge:(Record*)record;

@end
