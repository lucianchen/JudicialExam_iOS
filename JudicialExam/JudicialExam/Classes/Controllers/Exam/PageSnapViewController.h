//
//  PageSnapViewController.h
//  JudicialExam
//
//  Created by Chen, Liang on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaperPageSelector.h"

@interface PageSnapViewController : UIViewController{
    PaperPageSelector *pageSelector;
}

@property(nonatomic, assign) PaperPageSelector *pageSelector;

@end
