//
//  WMEditPOICategoryViewController.m
//  Wheelmap
//
//  Created by Andrea Gerlach on 12.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMEditPOICategoryViewController.h"
#import "WMDataManager.h"
#import "WMCategory.h"
#import "WMEditPOIViewController.h"

@interface WMEditPOICategoryViewController ()

@end

@implementation WMEditPOICategoryViewController

- (id)initWithStyle:(UITableViewStyle)style andCategory:(WMCategory*)c
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"EditPOIViewCategoryLabel", @"");
    self.navigationBarTitle = self.title;
    
    self.tableView.scrollsToTop = YES;
    
    long highlightedCellRow = -1;
    if (self.categoryArray != nil) {
        for (WMCategory* c in self.categoryArray) {
            if (c.id != nil && self.currentCategory != nil && self.currentCategory.id != nil) {
                if (c.id.intValue == self.currentCategory.id.intValue) {
                    highlightedCellRow = [self.categoryArray indexOfObject:c];
                }
            }
        }
    }
    
    if (highlightedCellRow >= 0) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:highlightedCellRow inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.categoryArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WMCategory *cat = [self.categoryArray objectAtIndex:indexPath.row];
    NSString *catString = cat.localized_name;
    static NSString *CellIdentifier = @"CategoryCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = catString;
   
    /*
    if (indexPath.row == self.selectedRow) {
        cell.accessoryType =  UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    */
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 36;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WMCategory *cat = [self.categoryArray objectAtIndex:indexPath.row];
    [self.delegate categoryChosen:cat];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
