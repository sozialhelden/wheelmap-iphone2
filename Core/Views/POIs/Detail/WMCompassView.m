//
//  WMCompassView.m
//  Wheelmap
//
//  Created by Andrea Gerlach on 10.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMCompassView.h"

#define degreesToRadians(x) (M_PI * x / 180.0)
#define RAD_TO_DEG(r) ((r) * (180 / M_PI))
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@implementation WMCompassView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self initView];
    }
    return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];

	[self initView];
}

- (void)initView {
	UIImage *compass = [UIImage imageNamed:@"details_compass.png"];
	UIImageView *arrowImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, compass.size.width, compass.size.height)];
	arrowImg.image = compass;

	self.compassContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, compass.size.width, compass.size.height)];

	[self.compassContainer addSubview:arrowImg];
	[self addSubview:self.compassContainer];
	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	self.locationManager.delegate=self;
	// Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
	if (IS_OS_8_OR_LATER) {
		if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
			[self.locationManager requestWhenInUseAuthorization];
		}
	}
	[self.locationManager startUpdatingLocation];

	//Start the compass updates.
	[self.locationManager startUpdatingHeading];


	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopUpdating:) name:UIApplicationDidEnterBackgroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startUpdating:) name:UIApplicationDidBecomeActiveNotification object:nil];

	if(IS_OS_8_OR_LATER) {
		[self.locationManager requestWhenInUseAuthorization];
	}

	if ([CLLocationManager locationServicesEnabled]){
		[self.locationManager startUpdatingLocation];

		//Start the compass updates.
		[self.locationManager startUpdatingHeading];
	}
	self.currentLocation = [CLLocation new];
}

- (void)startUpdating:(NSNotification*)notification {
    if(IS_OS_8_OR_LATER) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingHeading];
    [self.locationManager startUpdatingLocation];
}

- (void)stopUpdating:(NSNotification*)notification {
    [self.locationManager stopUpdatingHeading];
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    self.currentLocation = newLocation;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    self.currentLocation = [locations lastObject];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    
    self.nodeLocation = [[CLLocation alloc] initWithLatitude:self.node.lat.doubleValue longitude:self.node.lon.doubleValue];
    
    float angle = [self angleFromCoordinate:self.currentLocation.coordinate toCoordinate:self.nodeLocation.coordinate];
    
    CLLocationDegrees oldDegrees = RAD_TO_DEG(angle);
 
    float newDegrees = oldDegrees - 180;
    if (newDegrees < 0) {
        newDegrees = newDegrees + 360;
    }
    
    
	NSInteger magneticAngle = newHeading.magneticHeading;
    NSInteger trueAngle = newHeading.trueHeading;

    //This is set by a switch in my apps settings //
    
    NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
    BOOL magneticNorth = [prefs boolForKey:@"UseMagneticNorth"];
    
    float newAngle;
    
    if (magneticNorth == YES) {
        newAngle = newDegrees-magneticAngle;
        
        CGAffineTransform rotate = CGAffineTransformMakeRotation(degreesToRadians(newAngle));
        [self.compassContainer setTransform:rotate];
    } else {        
        newAngle = newDegrees-trueAngle;
        
        CGAffineTransform rotate = CGAffineTransformMakeRotation(degreesToRadians(newAngle));
        [self.compassContainer setTransform:rotate];
    }

}


- (float)angleFromCoordinate:(CLLocationCoordinate2D)poi toCoordinate:(CLLocationCoordinate2D)user {
    
    float longitudinalDifference    = poi.longitude - user.longitude;
    float latitudinalDifference     = poi.latitude  - user.latitude;
    float possibleAzimuth           = (M_PI * .5f) - atan(latitudinalDifference / longitudinalDifference);
    
    if (longitudinalDifference > 0)
        return possibleAzimuth;
    else if (longitudinalDifference < 0)
        return possibleAzimuth + M_PI;
    else if (latitudinalDifference < 0)
        return M_PI;
    
    return 0.0f;
}

- (void) dealloc {
    // Removing observers
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
}




 
@end
