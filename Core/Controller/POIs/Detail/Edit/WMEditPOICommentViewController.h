//
//  WMEditPOICommentViewController.h
//  Wheelmap
//
//  Created by Andrea Gerlach on 03.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Node.h"
#import "WMDataManager.h"

@interface WMEditPOICommentViewController : WMViewController <WMDataManagerDelegate>

@property (nonatomic, strong) WMDataManager *		dataManager;
@property (strong, nonatomic) Node *				currentNode;

- (void)saveEditedData;

@end