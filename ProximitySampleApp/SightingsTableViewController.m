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
#import "SightingsTableViewController.h"
#import "SightingsTableViewCell.h"
#import "Transmitter.h"

#import <FYX/FYX.h>
#import <FYX/FYXVisitManager.h>
#import <FYX/FYXSightingManager.h>
#import <FYX/FYXTransmitter.h>
#import <FYX/FYXVisit.h>
#import <CoreLocation/CoreLocation.h>


@interface SightingsTableViewController () <UITableViewDelegate, UITableViewDataSource, FYXServiceDelegate, FYXVisitDelegate, CLLocationManagerDelegate>


@property NSMutableArray *transmitters;
@property FYXVisitManager *visitManager;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;


@end




@implementation SightingsTableViewController {
    CLLocationManager *manager;
    CLLocation *loc;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    NSMutableString *LastGPS;
}

- (void)viewDidLoad
{
    manager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    loc = [[CLLocation alloc] init];
    
    [super viewDidLoad];
    
    [FYX startService:self];
    
    //Testing getting a list of beacons.  Need to call url and store JSON string into _JSONString
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://rochesterswhiteparty.com/Beacon/act.php?ACTION=GetBeaconInfoALL"]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    //NSLog (_responseData);
}

- (void)dealloc
{
    [self.visitManager stop];
}

#pragma mark - FYX Delegate methods

- (void)serviceStarted
{
    NSLog(@"#########Proximity service started!");
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"fyx_service_started_key"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.transmitters = [NSMutableArray new];
    
    [self.navigationController.navigationBar.topItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_icon_binoculars.png"]]];
    
    self.visitManager = [[FYXVisitManager alloc] init];
    self.visitManager.delegate = self;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //[self.visitManager startWithOptions:@{FYXVisitOptionDepartureIntervalInSecondsKey:@15,
     //                                     FYXSightingOptionSignalStrengthWindowKey:@(FYXSightingOptionSignalStrengthWindowNone)}];
    
    [self.visitManager startWithOptions:@{FYXVisitOptionDepartureIntervalInSecondsKey:@5}];
    
}

- (void)startServiceFailed:(NSError *)error
{
    NSLog(@"#########Proximity service failed to start! error is: %@", error);
    
    NSString *message = @"Service failed to start, please check to make sure your Application Id and Secret are correct.";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Proximity Service"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - FYX visit delegate

- (void)didArrive:(FYXVisit *)visit
{
    //NSLog(@"didArrive: %@", visit.transmitter.name);
    NSMutableString *URL = [NSMutableString string];
    [URL appendString:@"http://www.rochesterswhiteparty.com/Beacon/act.php"];
    [URL appendString:@"?ACTION=LogArrival"];
    [URL appendString:@"&BeaconName="];
    [URL appendString:visit.transmitter.name];
    manager.delegate = self;
    manager.desiredAccuracy = kCLLocationAccuracyBest;
    [manager startUpdatingLocation];
    [URL appendString:@"&CheckpointID=6"];  //Will need to use a query to determine ID from Name
    [URL appendString:@"&GPS="];
     [URL appendString:[NSString stringWithFormat:@"%f",loc.coordinate.latitude]];
     [URL appendString:@","];
     [URL appendString:[NSString stringWithFormat:@"%f",loc.coordinate.longitude]];
    [URL appendString:@"&Time="];
    [URL appendString:[self timeStamp]];
    //NSLog( URL);
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL]];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    Transmitter *t = [[self.transmitters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", visit.transmitter.identifier]] firstObject];
    t.LastAction = [NSString stringWithFormat:@"Arrival"];
    
}

- (void)didDepart:(FYXVisit *)visit
{
   
    //NSLog(@"didDepart: %@", visit.transmitter.name);
    NSMutableString *URL = [NSMutableString string];
    [URL appendString:@"http://www.rochesterswhiteparty.com/Beacon/act.php"];
    [URL appendString:@"?ACTION=LogDeparture"];
    [URL appendString:@"&BeaconName="];
    [URL appendString:visit.transmitter.name];
    [URL appendString:@"&CheckpointID=6"];  //Will need to use a query to determine ID from Name
    [URL appendString:@"&GPS="];
    [URL appendString:[NSString stringWithFormat:@"%f",loc.coordinate.latitude]];
    [URL appendString:@","];
    [URL appendString:[NSString stringWithFormat:@"%f",loc.coordinate.longitude]];
    [URL appendString:@"&Time="];
    [URL appendString:[self timeStamp]];
    //NSLog (URL);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];

    
    Transmitter *transmitter = [[self.transmitters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", visit.transmitter.identifier]] firstObject];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.transmitters indexOfObject:transmitter] inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

    transmitter.LastAction = [NSString stringWithFormat:@"Departure"];
    if ([cell isKindOfClass:[SightingsTableViewCell class]])
    {
        //[self grayOutSightingsCell:((SightingsTableViewCell*)cell)];
        [self updateSightingsCell:cell withTransmitter:transmitter];
    }
}

- (void)receivedSighting:(FYXVisit *)visit updateTime:(NSDate *)updateTime RSSI:(NSNumber *)RSSI
{
    //NSLog(@"############## receivedSighting: %@", visit);
    
    Transmitter *transmitter = [[self.transmitters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", visit.transmitter.identifier]] firstObject];
   
    //NSLog(@"Sighting: %@", transmitter.identifier);
    if (transmitter == nil)
    {
        transmitter = [Transmitter new];
        transmitter.identifier = visit.transmitter.identifier;
        transmitter.name = visit.transmitter.name ? visit.transmitter.name : visit.transmitter.identifier;
        transmitter.lastSighted = [NSDate dateWithTimeIntervalSince1970:0];
        transmitter.rssi = [NSNumber numberWithInt:-100];
        transmitter.previousRSSI = transmitter.rssi;
        transmitter.batteryLevel = 0;
        transmitter.temperature = 0;
        
        [self.transmitters addObject:transmitter];
        
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.transmitters.count - 1 inSection:0]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        
        
        if ([self.transmitters count] == 1)
        {
            [self hideNoTransmittersView];
        }
    }
    
    transmitter.lastSighted = updateTime;
    
    if ([self shouldUpdateTransmitterCell:visit transmitter:transmitter RSSI:RSSI])
    {
        transmitter.previousRSSI = transmitter.rssi;
        transmitter.rssi = RSSI;
        transmitter.batteryLevel = visit.transmitter.battery;
        transmitter.temperature = visit.transmitter.temperature;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.transmitters indexOfObject:transmitter] inSection:0];
        
        SightingsTableViewCell *cell = (SightingsTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];

        [self updateSightingsCell:cell withTransmitter:transmitter];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.transmitters count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MyReusableCell";
    SightingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell != nil)
    {
        Transmitter *transmitter = [self.transmitters objectAtIndex:indexPath.row];
        
        cell.transmitterNameLabel.text = transmitter.ArrivalFirstName;
        cell.transmitterIcon.image = [UIImage imageNamed:@"avatar_01"];
        
        
        if ([self isTransmitterAgedOut:transmitter])
        {
            //[self grayOutSightingsCell:cell];
            //Dont grey out - update that the user departed
            [self updateSightingsCell:cell withTransmitter:transmitter];
            
        }
        else
        {
            [self updateSightingsCell:cell withTransmitter:transmitter];
            
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Transmitter *transmitter = [self.transmitters objectAtIndex:indexPath.row];
        [self.transmitters removeObject:transmitter];
        if ([self.transmitters count] == 0)
        {
            [self showNoTransmittersView];
        }
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (float)barWidthForRSSI:(NSNumber *)rssi
{
    NSInteger barMaxValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"rssi_bar_max_value"];
    NSInteger barMinValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"rssi_bar_min_value"];
    
    float rssiValue = [rssi floatValue];
    float barWidth;
    if (rssiValue >= barMaxValue)
    {
        barWidth = 270.0f;
    }
    else if (rssiValue <= barMinValue)
    {
        barWidth = 5.0f;
    } else
    {
        NSInteger barRange = barMaxValue - barMinValue;
        float percentage = (barMaxValue - rssiValue) / (float)barRange;
        barWidth = (1.0f - percentage) * 270.0f;
    }
    return barWidth;
}



- (UIImage *)batteryImageForLevel:(NSNumber *)batteryLevel
{
    switch([batteryLevel integerValue])
    {
        case 0:
        case 1:
            return [UIImage imageNamed:@"battery_low.png"];
        case 2:
            return [UIImage imageNamed:@"battery_high.png"];
        case 3:
            return [UIImage imageNamed:@"battery_full.png"];
        default:
            return [UIImage imageNamed:@"battery_unknown.png"];
    }
}

- (void)updateSightingsCell:(SightingsTableViewCell *)sightingsCell withTransmitter:(Transmitter *)transmitter
{
    if (sightingsCell && transmitter)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            sightingsCell.contentView.alpha = 1.0f;
            
            
            sightingsCell.isGrayedOut = NO;
            UIImage *batteryImage = [self batteryImageForLevel:transmitter.batteryLevel];
            [sightingsCell.batteryImageView setImage:batteryImage];
            sightingsCell.temperature.text = [NSString stringWithFormat:@"%@%@", transmitter.temperature,
                                              [NSString stringWithUTF8String:"\xC2\xB0 F" ]];
            sightingsCell.rssiLabel.text = [NSString stringWithFormat:@"%@", transmitter.rssi];
            //Set the status of the cell.  Usually this is arrived
            if ( [transmitter.LastAction isEqualToString:[NSString stringWithFormat:@"Arrival"]]){
                //Arrival
                sightingsCell.BeaconStatusLabel.text = [NSString stringWithFormat:@"Arrived at %@.\n[%@]", transmitter.ArrivalCheckpointName, [NSDate dateWithTimeIntervalSince1970:[transmitter.ArrivalTime doubleValue]]];
                sightingsCell.BeaconStatusLabel.backgroundColor = [UIColor greenColor];
               
            } else if ( [transmitter.LastAction isEqualToString:[NSString stringWithFormat:@"Departure"]]) {
                //Departure
                sightingsCell.BeaconStatusLabel.text = [NSString stringWithFormat:@"Departed from %@.\n[%@]", transmitter.ArrivalCheckpointName, [NSDate dateWithTimeIntervalSince1970:[transmitter.DepartureTime doubleValue]]];
                
                sightingsCell.BeaconStatusLabel.backgroundColor = [UIColor redColor];
            } else {
                //Unknown or somethign weird
                sightingsCell.BeaconStatusLabel.text = [NSString stringWithFormat:@"Unknown"];
                sightingsCell.BeaconStatusLabel.backgroundColor = [UIColor grayColor];
            }
            
            
        });
    }
}

- (BOOL)shouldUpdateTransmitterCell:(FYXVisit *)visit transmitter:(Transmitter *)transmitter RSSI:(NSNumber *)rssi
{
    if ([transmitter.rssi isEqual:rssi] &&
        [transmitter.batteryLevel isEqualToNumber:visit.transmitter.battery] &&
        [transmitter.temperature isEqualToNumber:visit.transmitter.temperature])
    {
        return NO;
    }
    return YES;
}

- (BOOL)isTransmitterAgedOut:(Transmitter *)transmitter
{
    NSDate *now = [NSDate date];
    NSTimeInterval ageOutPeriod = [[NSUserDefaults standardUserDefaults] integerForKey:@"age_out_period"];
    
    if ([now timeIntervalSinceDate:transmitter.lastSighted] > ageOutPeriod) {
        return YES;
    }
    return NO;
}


#pragma mark - User interface manipulation

- (void)hideNoTransmittersView
{
    self.loadingView.hidden = YES;
}

- (void)showNoTransmittersView
{
    self.loadingView.hidden = NO;
}

#pragma mark - Storyboard interation

- (IBAction)refreshButtonClicked:(id)sender
{
    [self showNoTransmittersView];
    [self.transmitters removeAllObjects];
    [self.tableView reloadData];
}


#pragma mark NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //a respononse has been recieved
    //initalize the variable _responseData and clear it in subsequent connections
    
    //will append to this in didRecieveData
    _responseData = [[NSMutableData alloc] init];
   // NSLog(@"Did Recieve Response");
    
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //append new data to the _responseData variable
    [_responseData appendData:data];
   // NSLog(@"Did Recieve Data");
    
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    //    NSLog(@"Will Cache Repsonse");
    return nil;
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //request complete and data recieved.. you can parse it now
    //    NSLog(@"Connection Did Finnish Loading");
    //NSString *dataString = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    //NSLog (dataString);
    NSError *error; //needs error in case JSON parsing fails
    NSMutableDictionary *result = [NSJSONSerialization JSONObjectWithData:_responseData options:NSJSONReadingMutableContainers error:&error];
    //NSLog(@"%@", result[@"Beacon1"]);
    if (error )
    {
        NSLog(@"%@", [error localizedDescription]);
    }
    else {
        
        NSMutableString *e;
        [e appendString:result[@"error"]];
        [e appendString:result[@"mysql_error"]];
        
        NSMutableString *ActionReturned;  //If it is a log event, it is the Action
                                            // If it is a get event it is the result"0"
        if (result[@"Action"] == nil) {
            ActionReturned = result[@"0"] ;
        } else {
            ActionReturned = result[@"Action"] ;

        }
        
        if (e ==(id)[NSNull null] || e.length == 0) {
            NSLog(@"Action: %@ | SUCCESS!", ActionReturned );
        } else {
            NSLog(@"Action: %@ | FAILURE! %@", ActionReturned, e );
        }
        //NSLog (result[@"0"]);
        //Test Action and log appropriate data here

        if ([result[@"0"]  isEqual: @"GetBeaconInfoALL"]) {
            //Get beacon info all
            NSLog(@"Get beacon info all - load the (inital) dictionary of all beacons status");
            
           
            
            for(id key in result) {
                NSString *BeaconName = [NSString stringWithFormat:@"%@", key];
                //NSLog(@"%@",BeaconName);
                //NSLog(@"%@",key);
                
                
                //If it is a Becond (meaning key is of type Beacon__) then we can do more
                // if not, we will get an error
                if ([BeaconName length] >= 6) {   //need 6 characters or next step fails
                    if ([[BeaconName substringToIndex:6] isEqualToString:@"Beacon"] || [[BeaconName substringToIndex:6] isEqualToString:@"BEACON"]) {
                        //we're ok
                        NSMutableDictionary *d = [result objectForKey:BeaconName];
                        NSLog(@"BeaconName: %@ BeaconID: %@ LastAction: %@", [d objectForKey:@"BeaconName"],[d objectForKey:@"BeaconFactoryID"],[d objectForKey:@"LastAction"] );
                        
                        
                        
                        Transmitter *transmitter = [[self.transmitters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", [d objectForKey:@"BeaconName"]]] firstObject];
                        
                        if (transmitter == nil)
                        {
                            transmitter = [Transmitter new];
                            transmitter.identifier = [d objectForKey:@"BeaconFactoryID"];
                            transmitter.name = [d objectForKey:@"BeaconName"];
                            //transmitter.lastSighted = [NSDate dateWithTimeIntervalSince1970:0];
                            transmitter.rssi = [NSNumber numberWithInt:-100];
                            transmitter.previousRSSI = [NSNumber numberWithInt:-100];
                            transmitter.batteryLevel = 0;
                            transmitter.temperature = 0;
                            
                            transmitter.Hardware = [d objectForKey:@"BeaconHardware"];
                            //transmitter.LastAction = [d objectForKey:@"LastAction"];
                            transmitter.LastAction = [NSString stringWithFormat:@"Unknown"];
                            transmitter.ArrivalID = [d objectForKey:@"ArrivalID"];
                            transmitter.ArrivalTime = [d objectForKey:@"ArrivalTime"];
                            transmitter.ArrivalCheckpointID = [d objectForKey:@"ArrivalCheckpointID"];
                            transmitter.ArrivalCheckpointName = [d objectForKey:@"ArrivalCheckpointName"];
                            transmitter.ArrivalGPS = [d objectForKey:@"ArrivalGPS"];
                            transmitter.ArrivalFirstName = [d objectForKey:@"ArrivalFirstName"];
                            transmitter.ArrivalLastName = [d objectForKey:@"ArrivalLastName"];
                            transmitter.ArrivalCellPhone = [d objectForKey:@"ArrivalCellPhone"];
                            transmitter.ArrivalEmail = [d objectForKey:@"ArrivalEmail"];
                            transmitter.DepartureID = [d objectForKey:@"DepartureID"];
                            transmitter.DepartureTime = [d objectForKey:@"DepartureTime"];
                            transmitter.DepartureCheckpointID = [d objectForKey:@"DepartureCheckpointID"];
                            transmitter.DepartureCheckpointName = [d objectForKey:@"DepartureCheckpointName"];
                            transmitter.DepartureGPS = [d objectForKey:@"DepartureGPS"];
                            transmitter.DepartureFirstName = [d objectForKey:@"DepartureFirstName"];
                            transmitter.DepartureLastName = [d objectForKey:@"DepartureLastName"];
                            transmitter.DepartureCellPhone = [d objectForKey:@"DepartureCellPhone"];
                            transmitter.DepartureEmail = [d objectForKey:@"DepartureEmail"];
                            
                            [self.transmitters addObject:transmitter];
                            
                            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.transmitters.count - 1 inSection:0]]
                                                  withRowAnimation:UITableViewRowAnimationAutomatic];
                            
                            if ([self.transmitters count] == 1)
                            {
                                [self hideNoTransmittersView];
                            }

                        }
                        
                       
                        
                        
                        
                        
                }
                
                    
                }
                
            }
            
        }
        if ([result[@"0"]  isEqual: @"GetBeaconInfo"]) {
            //Get beacon info all
            NSLog(@"Get beacon info update information on a specific beacon");
            
        }
        if ([result[@"0"]  isEqual: @"GetBeaconDetails"]) {
            //Get beacon info all
            NSLog(@"Get beacon details");
        }
        if ([result[@"0"]  isEqual: @"GetBeaconDetailsALL"]) {
            //Get beacon info all
            NSLog(@"Get beacon details all");
        }

        
        
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //the request failed
        NSLog(@"Connection Failed");
}


- (NSString *)timeStamp {
    return [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
}


#pragma mark CLLocationManagerDelagate Methods
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error:%@", error);
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
   // NSLog(@"Location: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        loc = currentLocation;
        
    }
}
@end
