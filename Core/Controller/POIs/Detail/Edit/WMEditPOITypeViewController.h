//
//  WMEditPOITypeViewController.h
//  Wheelmap
//
//  Created by Andrea Gerlach on 12.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NodeType.h"

@interface WMEditPOITypeViewController : WMTableViewController

@property (nonatomic, strong) NSArray *		nodeArray;
@property (strong, nonatomic) id			delegate;
@property (strong, nonatomic) NodeType *	currentNodeType;

@end