//
//  WMMapAnnotation.h
//  Wheelmap
//
//  Created by Dorian Roy on 08.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@class Node;


@interface WMMapAnnotation : NSObject<MKAnnotation>

- (id) initWithNode:(Node*)node;

@property (nonatomic) Node* node;

@end
