//
//  WMMoreInfoViewController.h
//  Wheelmap
//
//  Created by Andrea Gerlach on 04.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Node.h"

@interface WMMoreInfoViewController : WMViewController
@property (nonatomic, strong) Node *node;
@property (weak, nonatomic) IBOutlet UITextView *moreInfoTextView;

@end
