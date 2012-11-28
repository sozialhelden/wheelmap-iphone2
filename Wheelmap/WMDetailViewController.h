//
//  WMDetailViewController.h
//  Wheelmap
//
//  Created by Dorian Roy on 09.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Node;

@interface WMDetailViewController : UIViewController

@property (nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic) IBOutlet UILabel *nodeTypeLabel;

@property (nonatomic) Node *node;

@end
