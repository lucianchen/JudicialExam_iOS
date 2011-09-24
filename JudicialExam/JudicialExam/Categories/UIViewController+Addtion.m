//
//  UIViewController+Addtion.m
//  JudicialExam
//
//  Created by Chen, Liang on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIViewController+Addtion.h"

@implementation UIViewController(JudicialExam)

- (BOOL)isDeviceOrientationPortrait{
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	BOOL isPortrait = NO;
	if (orientation == UIDeviceOrientationFaceUp || 
		orientation == UIDeviceOrientationFaceDown||
		orientation == UIDeviceOrientationUnknown) {
		isPortrait = (self.interfaceOrientation == UIInterfaceOrientationPortrait) || 
		(self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
	}else {
		isPortrait = (orientation == UIInterfaceOrientationPortrait) || 
		(orientation == UIInterfaceOrientationPortraitUpsideDown);
	}
	
	return isPortrait;
}

@end
