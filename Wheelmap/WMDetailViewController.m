//
//  WMDetailViewController.m
//  Wheelmap
//
//  Created by Dorian Roy on 09.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMDetailViewController.h"
#import "Node.h"
#import "NodeType.h"

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
    
    // show name
    self.titleLabel.text = self.node.name ?: @"?";
    
    // show node type
    self.nodeTypeLabel.text = self.node.node_type.localized_name ?: @"?";
}

/* Set a fixed size for view in popovers */

- (CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(320, 480);
}


@end

