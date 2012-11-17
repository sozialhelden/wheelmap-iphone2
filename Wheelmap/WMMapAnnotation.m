//
//  WMMapAnnotation.m
//  Wheelmap
//
//  Created by Dorian Roy on 08.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMMapAnnotation.h"


@implementation WMMapAnnotation
{
    CLLocationCoordinate2D _coordinate;
}


- (id) initWithNode:(NSDictionary *)node
{
    self = [super init];
    if (self) {
        self.node = node;
        _coordinate = CLLocationCoordinate2DMake([node[@"lat"] doubleValue], [node[@"lon"] doubleValue]);
    }
    return self;
}

- (CLLocationCoordinate2D) coordinate
{
    return _coordinate;
}

- (void) setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    _coordinate = newCoordinate;
}

- (NSString*) title
{
    return [[self.node allKeys] indexOfObject:@"name"]==NSNotFound || self.node[@"name"]==[NSNull null] ? @"?" : self.node[@"name"];
}

- (NSString*) subtitle
{
    NSDictionary *nodeType = [[self.node allKeys] indexOfObject:@"node_type"]==NSNotFound || self.node[@"node_type"]==[NSNull null] ? nil : self.node[@"node_type"];
    NSString *nodeTypeIdentifier = nil;
    if (nodeType) {
        nodeTypeIdentifier = [[nodeType allKeys] indexOfObject:@"identifier"]==NSNotFound || nodeType[@"identifier"]==[NSNull null] ? nil : nodeType[@"identifier"];
    }
    return nodeTypeIdentifier;
}


@end


