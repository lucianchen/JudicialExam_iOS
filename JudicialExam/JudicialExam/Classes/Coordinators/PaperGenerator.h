//
//  PaperGenerator.h
//  JudicialExam
//
//  Created by Chen, Liang on 9/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Paper.h"
#import "Types.h"

@interface PaperGenerator : NSObject{
    
}

- (Paper*)paperFromSettings:(ExamPreSettings)settings;

@end
