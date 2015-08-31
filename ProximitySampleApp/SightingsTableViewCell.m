/**
 * Copyright (C) 2014 Gimbal, Inc. All rights reserved.
 *
 * This software is the confidential and proprietary information of Gimbal, Inc.
 *
 * The following sample code illustrates various aspects of the Gimbal SDK.
 *
 * The sample code herein is provided for your convenience, and has not been
 * tested or designed to work on any particular system configuration. It is
 * provided AS IS and your use of this sample code, whether as provided or
 * with any modification, is at your own risk. Neither Gimbal, Inc.
 * nor any affiliate takes any liability nor responsibility with respect
 * to the sample code, and disclaims all warranties, express and
 * implied, including without limitation warranties on merchantability,
 * fitness for a specified purpose, and against infringement.
 */
#import "SightingsTableViewCell.h"

@implementation SightingsTableViewCell

// Method to re-arrange subviews within the custom cell
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.0f];
    
    for (UIView *subview in self.subviews) {
        if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"]) {
            
            // Correctly align the delete button within the custom cell
            CGRect newFrame = subview.frame;
            newFrame.origin.x = 230;
            newFrame.origin.y = -9;
            subview.frame = newFrame;
        }
    }
    [UIView commitAnimations];
}

@end
