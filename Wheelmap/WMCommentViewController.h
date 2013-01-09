//
//  WMCommentViewController.h
//  Wheelmap
//
//  Created by Andrea Gerlach on 03.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Node.h"
#import "WMDataManager.h"

@interface WMCommentViewController : WMViewController <WMDataManagerDelegate> {
    UIActivityIndicatorView* progressWheel;
}

@property (weak, nonatomic) IBOutlet UITextView *commentText;

@property (nonatomic, strong) WMDataManager *dataManager;

@property (strong, nonatomic) Node *currentNode;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

- (void) saveEditedData;

@end
