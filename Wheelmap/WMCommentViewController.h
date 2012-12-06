//
//  WMCommentViewController.h
//  Wheelmap
//
//  Created by Andrea Gerlach on 03.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Node.h"

@interface WMCommentViewController : WMViewController

@property (weak, nonatomic) IBOutlet UITextView *commentText;

@property (strong, nonatomic) Node *currentNode;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

@end
