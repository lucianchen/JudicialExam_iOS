//
//  CellUtil.h
//  JudicialExam
//
//  Created by Chen, Liang on 9/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OptionCell.h"
#import "Option.h"

@interface CellUtil : NSObject

+(void)configureCell:(OptionCell*)cell forOption:(Option*)option;

@end
