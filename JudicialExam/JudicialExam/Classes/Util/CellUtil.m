//
//  CellUtil.m
//  JudicialExam
//
//  Created by Chen, Liang on 9/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CellUtil.h"
#import "Types.h"

@interface CellUtil()
+ (NSString*)paperTypeStringByType:(PaperType)type;
@end

@implementation CellUtil

+(void)configureCell:(OptionCell*)cell forOption:(Option*)option{
    cell.textView.text = option.desc;
}

+(void)configureCell:(QuestionListCell*)cell forQuestion:(Question*)question{
    QuestionListCell *listCell = (QuestionListCell*)cell;
    listCell.questionText.text = question.title;
    listCell.yearLabel.text = [NSString stringWithFormat:@"%@", question.year];
    
    
    listCell.paperTypeLabel.text = [CellUtil paperTypeStringByType:[question.paperType intValue]];
    listCell.questionIdLabel.text = [NSString stringWithFormat:@"%@", question.Id];
}

+ (NSString*)paperTypeStringByType:(PaperType)type{
    NSString *retval = nil;
    
    switch (type) {
        case PaperTypeOne:
            retval = @"卷一";
            break;
        case PaperTypeTwo:
            retval = @"卷二";
            break;case PaperTypeThree:
            retval = @"卷三";
            break;
            
        default:
            break;
    }
    
    return retval;
}

@end
