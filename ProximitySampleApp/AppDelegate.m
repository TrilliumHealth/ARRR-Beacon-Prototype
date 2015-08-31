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
#import "AppDelegate.h"

#import <FYX/FYX.h>
#import <FYX/FYXLogging.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self registerInitialValuesForUserDefaults];
    
    [FYX setAppId:@"12f2a358bcd078b368562077b662ae06f46eb44ca16d704c6b449129ceb56f37"
        appSecret:@"d75ebd6aa2212393066827e76248d58abc5181bedcd36c68e39ee23a541a1891"
      callbackUrl:@"trilliumbeacondetector://authcode"];
    [FYXLogging setLogLevel:FYX_LOG_LEVEL_INFO];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    if ([self isProximityEnabled])
    {
        self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"SightingsTableViewController"];
    }
    else
    {
        self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"EnableProximityViewController"];
    }
    
    
    
    return YES;
}

- (BOOL)isProximityEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"fyx_service_started_key"];
}

- (void)registerInitialValuesForUserDefaults {
    
    // Get the path of the settings bundle (Settings.bundle)
    NSString *settingsBundlePath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if (!settingsBundlePath) {
        NSLog(@"ERROR: Unable to locate Settings.bundle within the application bundle!");
        return;
    }
    
    // Get the path of the settings plist (Root.plist) within the settings bundle
    NSString *settingsPlistPath = [[NSBundle bundleWithPath:settingsBundlePath] pathForResource:@"Root" ofType:@"plist"];
    if (!settingsPlistPath) {
        NSLog(@"ERROR: Unable to locate Root.plist within Settings.bundle!");
        return;
    }
    
    // Create a new dictionary to hold the default values to register
    NSMutableDictionary *defaultValuesToRegister = [NSMutableDictionary new];
    
    // Iterate over the preferences found in the settings plist
    NSArray *preferenceSpecifiers = [[NSDictionary dictionaryWithContentsOfFile:settingsPlistPath] objectForKey:@"PreferenceSpecifiers"];
    for (NSDictionary *preference in preferenceSpecifiers) {
        
        NSString *key = [preference objectForKey:@"Key"];
        id defaultValueObject = [preference objectForKey:@"DefaultValue"];
        
        if (key && defaultValueObject) {
            // If a default value was found, add it to the dictionary
            [defaultValuesToRegister setObject:defaultValueObject forKey:key];
        }
    }

    // Register the initial values in UserDefaults that were found in the settings bundle
    if (defaultValuesToRegister.count > 0) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults registerDefaults:defaultValuesToRegister];
        [userDefaults synchronize];
    }
}

@end
