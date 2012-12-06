//
//  WMCategoryViewController.h
//  Wheelmap
//
//  Created by npng on 12/4/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMViewController.h"
#import "WMDataManager.h"
#import "Category.h"

@interface WMCategoryViewController : WMViewController <UITableViewDataSource, UITableViewDelegate>
{
    WMDataManager* dataManager;
    
    NSArray* categories;
}
@property (nonatomic, strong) IBOutlet UITableView* tableView;
@end
