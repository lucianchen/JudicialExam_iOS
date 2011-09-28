//
//  SummaryProtocol.h
//  JudicialExam
//
//  Created by Chen, Liang on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef JudicialExam_SummaryProtocol_h
#define JudicialExam_SummaryProtocol_h

@protocol ExamSummaryDelegate <NSObject>

- (void)didSelectItemForPage:(NSInteger)page;
- (void)dismissSummaryInfo;

@end

#endif
