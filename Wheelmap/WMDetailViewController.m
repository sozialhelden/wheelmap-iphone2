//
//  WMDetailViewController.m
//  Wheelmap
//
//  Created by Dorian Roy on 09.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMDetailViewController.h"


@implementation WMDetailViewController


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Details";
	
    NSAssert(self.node, @"You need to set a node before this view controller can be presented");
    
    NSArray *keys = [self.node allKeys];
    
    // check name
    self.titleLabel.text = [keys indexOfObject:@"name"]==NSNotFound || self.node[@"name"]==[NSNull null] ? @"?" : self.node[@"name"];
    
    // check node type
    NSDictionary *nodeType = [keys indexOfObject:@"node_type"]==NSNotFound || self.node[@"node_type"]==[NSNull null] ? nil : self.node[@"node_type"];
    NSString *nodeTypeIdentifier = nil;
    if (nodeType) {
        nodeTypeIdentifier = [[nodeType allKeys] indexOfObject:@"identifier"]==NSNotFound || nodeType[@"identifier"]==[NSNull null] ? nil : nodeType[@"identifier"];
    }
    self.nodeTypeLabel.text = nodeTypeIdentifier;
}

/* Set a fixed size for view in popovers */

- (CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(320, 480);
}


@end

