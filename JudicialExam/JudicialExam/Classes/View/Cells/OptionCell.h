//
//  OptionCell.h
//  JudicialExam
//
//  Created by Chen, Liang on 9/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptionCell : UITableViewCell {
    UIImageView *checkStatusView;
    UIImageView *indexView;
    UITextView *textView;
    UIButton *checkButton;
}


@property (nonatomic, retain) IBOutlet UIImageView *checkStatusView;
@property (nonatomic, retain) IBOutlet UIImageView *indexView;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UIButton *checkButton;
@end
