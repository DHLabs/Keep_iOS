//
//  DHGeopointQuestionController.m
//  Keep
//
//  Created by Sean Patno on 8/12/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import "DHGeopointQuestionController.h"

#import <CoreLocation/CoreLocation.h>

@interface DHGeopointQuestionController ()<CLLocationManagerDelegate>
{
    CLLocationManager * locationManager;
    NSString * locationString;
}
@end

@implementation DHGeopointQuestionController

-(id) questionAnswer
{
    return @"";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    UIButton * logButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) logLiveLocation
{
    if([CLLocationManager locationServicesEnabled]) {

        if( !locationManager ) {
            locationManager = [[CLLocationManager alloc] init];
            locationManager.delegate = self;
            locationManager.distanceFilter = kCLDistanceFilterNone;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        }

        [locationManager startUpdatingLocation];
    }
}

-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //format is lat/long/altitude/location precision
    locationString = [NSString stringWithFormat:@"%f %f %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude, newLocation.altitude, newLocation.horizontalAccuracy];

    [locationManager stopUpdatingLocation];
}

@end
