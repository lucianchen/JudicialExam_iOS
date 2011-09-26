//
//  QuestionListCell.h
//  JudicialExam
//
//  Created by Chen, Liang on 9/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionListCell : UITableViewCell{
    UITextView *questionText;
    UILabel *paperTypeLabel;
    UILabel *yearLabel;
    UILabel *questionIdLabel;
    UILabel *idLabel;
}
@property (nonatomic, retain) IBOutlet UILabel *idLabel;

@property (nonatomic, retain) IBOutlet UITextView *questionText;
@property (nonatomic, retain) IBOutlet UILabel *paperTypeLabel;
@property (nonatomic, retain) IBOutlet UILabel *yearLabel;
@property (nonatomic, retain) IBOutlet UILabel *questionIdLabel;
@end
