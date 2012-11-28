//
//  WMMapAnnotation.m
//  Wheelmap
//
//  Created by Dorian Roy on 08.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMMapAnnotation.h"
#import "Node.h"
#import "NodeType.h"


@implementation WMMapAnnotation
{
    CLLocationCoordinate2D _coordinate;
}


- (id) initWithNode:(Node *)node
{
    self = [super init];
    if (self) {
        self.node = node;
        _coordinate = CLLocationCoordinate2DMake([node.lat doubleValue], [node.lon doubleValue]);
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
    return self.node.name ?: @"?";
}

- (NSString*) subtitle
{
    return self.node.node_type.localized_name ?: @"?";
}


@end


