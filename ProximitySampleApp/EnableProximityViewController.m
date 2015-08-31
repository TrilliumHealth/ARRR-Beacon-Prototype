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
#import "EnableProximityViewController.h"

#import <FYX/FYX.h>

@interface EnableProximityViewController () <FYXServiceDelegate>

@property (strong, nonatomic) IBOutlet UISwitch *proximityServiceSwitch;
@property (strong, nonatomic) IBOutlet UIView *proximityServiceSwitchView;
@property (strong, nonatomic) IBOutlet UIView *logoView;
@property (strong, nonatomic) IBOutlet UIView *switchView;

@end

@implementation EnableProximityViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupProximityEnableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self beginLoadingAnimation];
}

- (void)setupProximityEnableView
{
    UIView *v = self.switchView;
    [v.layer setCornerRadius:10.0f];
    [v.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [v.layer setBorderWidth:0.5f];
    [v.layer setShadowColor:[UIColor blackColor].CGColor];
    [v.layer setShadowOpacity:0.0];
    [v.layer setShadowRadius:0.0];
    [v.layer setShadowOffset:CGSizeMake(0.0, 0.0)];
}

- (void)beginLoadingAnimation
{
    [UIView animateWithDuration:0.9 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.logoView.transform = CGAffineTransformMakeTranslation(0.0, -70.0);
    } completion:^(BOOL finished) {
        [self.proximityServiceSwitchView setHidden:false];
    }];
}

- (void)presentSightingViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UINavigationController *controller = [storyboard instantiateViewControllerWithIdentifier:@"SightingsTableViewController"];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:controller animated:YES completion:^{
        id<UIApplicationDelegate> appDelegate = [UIApplication sharedApplication].delegate;
        appDelegate.window.rootViewController = controller;
        [appDelegate.window makeKeyAndVisible];
    }];
}

- (IBAction)proximityServiceSwitchChanged:(id)sender
{
    [self presentSightingViewController];
}

@end
