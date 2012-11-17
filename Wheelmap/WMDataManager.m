//
//  WMDataManager.m
//  Wheelmap
//
//  Created by Dorian Roy on 07.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMDataManager.h"
#import "WMWheelmapAPI.h"

#define WMSearchRadius 0.004


@implementation WMDataManager
{
    WMWheelmapAPI *api;
}

- (id) init
{
    self = [super init];
    if (self) {
        api = [[WMWheelmapAPI alloc] init];
    }
    return self;
}

- (void) fetchNodesNear:(CLLocationCoordinate2D)location
{
    // get rect of area within search radius around current location
    // this rect won"t have the same proportions as the map area on screen
    CLLocationCoordinate2D southwest = CLLocationCoordinate2DMake(location.latitude - WMSearchRadius, location.longitude - WMSearchRadius);
    CLLocationCoordinate2D northeast = CLLocationCoordinate2DMake(location.latitude + WMSearchRadius, location.longitude + WMSearchRadius);
    
    [self fetchNodesBetweenSouthwest:southwest northeast:northeast];
}

- (void) fetchNodesBetweenSouthwest:(CLLocationCoordinate2D)southwest northeast:(CLLocationCoordinate2D)northeast
{
    NSString *coords = [NSString stringWithFormat:@"%f,%f,%f,%f",
                         southwest.longitude,
                         southwest.latitude,
                         northeast.longitude,
                         northeast.latitude];
    [self fetchNodesWithParameters:@{@"bbox":coords}];
}

- (void) fetchNodesWithParameters:(NSDictionary*)parameters;
{
    [api requestResource:@"nodes"
              parameters:parameters
                    data:nil
                  method:nil
                   error:^(NSError *error) {
                       NSLog(@"error getting nodes");
                   }
                 success:^(NSDictionary *data) {
                     [self receivedNodes:data[@"nodes"]];
                 }
     ];
}

- (void) receivedNodes:(NSArray*)nodes
{
    // TODO: cache nodes
    [self.delegate receivedNodes:nodes];
}

@end

