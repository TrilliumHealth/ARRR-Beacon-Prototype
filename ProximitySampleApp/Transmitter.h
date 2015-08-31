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
#import <Foundation/Foundation.h>

@interface Transmitter : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSNumber *rssi;
@property (nonatomic, strong) NSNumber *previousRSSI;
@property (nonatomic, strong) NSDate *lastSighted;
@property (nonatomic, strong) NSNumber *batteryLevel;
@property (nonatomic, strong) NSNumber *temperature;

//ADDED FOR AJ
@property (nonatomic, strong) NSString *LastAction;
@property (nonatomic, strong) NSString *Hardware;

@property (nonatomic, strong) NSString  *ArrivalID;
@property (nonatomic, strong) NSString  *ArrivalTime;
@property (nonatomic, strong) NSString  *ArrivalCheckpointID;
@property (nonatomic, strong) NSString *ArrivalCheckpointName;
@property (nonatomic, strong) NSString *ArrivalGPS;
@property (nonatomic, strong) NSString *ArrivalFirstName;
@property (nonatomic, strong) NSString *ArrivalLastName;
@property (nonatomic, strong) NSString *ArrivalCellPhone;
@property (nonatomic, strong) NSString *ArrivalEmail;

@property (nonatomic, strong) NSString  *DepartureID;
@property (nonatomic, strong) NSString  *DepartureTime;
@property (nonatomic, strong) NSString  *DepartureCheckpointID;
@property (nonatomic, strong) NSString *DepartureCheckpointName;
@property (nonatomic, strong) NSString *DepartureGPS;
@property (nonatomic, strong) NSString *DepartureFirstName;
@property (nonatomic, strong) NSString *DepartureLastName;
@property (nonatomic, strong) NSString *DepartureCellPhone;
@property (nonatomic, strong) NSString *DepartureEmail;


@end
