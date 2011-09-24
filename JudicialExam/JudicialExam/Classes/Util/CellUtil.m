//
//  CellUtil.m
//  JudicialExam
//
//  Created by Chen, Liang on 9/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CellUtil.h"

@implementation CellUtil

+(void)configureCell:(OptionCell*)cell forOption:(Option*)option{
    cell.textView.text = option.desc;
}

@end
