//
//  PageSlider.m
//  JudicialExam
//
//  Created by Chen, Liang on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PageSlider.h"

#define ThumbnailImageEdgeLen (10)

@implementation PageSlider

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGRect)trackRectForBounds:(CGRect)bounds{
	CGRect orgTrackRect = [super trackRectForBounds:bounds];
	
	return CGRectInset(orgTrackRect, 0, 1.5);
}

- (UIImage *)thumbImageForState:(UIControlState)state{
	UIImage *image = nil;
	
	switch (state) {
		case UIControlStateNormal:
			image = [UIImage imageNamed:@"sliderButton.png"];
			break;
		default:
			image = [UIImage imageNamed:@"sliderButton_h.png"];
			break;
	}
	
	return image;
}

- (void)initThumbnailImages{
	NSArray *colorArray = [NSArray arrayWithObjects:
						   [UIColor colorWithWhite:1 alpha:1],		//Normal
						   [UIColor colorWithWhite:0.8 alpha:1],		//Highlighted
						   //							   [UIColor colorWithWhite:0.5 alpha:1],		//Disabled
						   //							   [UIColor colorWithWhite:0.7 alpha:1],		//Selected
						   nil];
	
	UIControlState state = UIControlStateNormal;
	CGRect rect = CGRectMake(0, 0, ThumbnailImageEdgeLen, ThumbnailImageEdgeLen);
	CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
	
	for (UIColor *color in colorArray) {
		CGContextRef bitmapContextRef = CGBitmapContextCreate(NULL,
															  ThumbnailImageEdgeLen,
															  ThumbnailImageEdgeLen,
															  8,
															  0,
															  cs,
															  kCGImageAlphaPremultipliedLast);
		
		CGContextSetFillColorWithColor(bitmapContextRef, [color CGColor]);
		CGContextFillEllipseInRect(bitmapContextRef, rect);
		
		CGContextSetStrokeColorWithColor(bitmapContextRef, [[UIColor darkGrayColor] CGColor]);
		CGContextStrokeEllipseInRect(bitmapContextRef, rect);
		
		CGImageRef buttonImageRef = CGBitmapContextCreateImage(bitmapContextRef);
		
		UIImage *thumbImage = [UIImage imageWithCGImage:buttonImageRef];
		[self setThumbImage:thumbImage forState:state];
		//[self setThumbImage:[UIImage imageNamed:@"play.png"] forState:state];
		
		state++;
		// Clean up
		CGContextRelease(bitmapContextRef);
		CGImageRelease(buttonImageRef);
	}
	
	CGColorSpaceRelease(cs);
}

- (void)dealloc {
    [super dealloc];
}

@end
