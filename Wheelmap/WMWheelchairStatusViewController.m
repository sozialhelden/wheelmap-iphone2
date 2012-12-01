//
//  WMWheelchairStatusViewController.m
//  Wheelmap
//
//  Created by Dorian Roy on 26.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMWheelchairStatusViewController.h"


@interface WMWheelchairStatusViewController ()

@end

@implementation WMWheelchairStatusViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


/* Set a fixed size for view in popovers */

- (CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(320, 480);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIImage *statusImage = [UIImage imageNamed:@"details_label-no.png"];
    UITableViewCell *cell = [UITableViewCell new];
    UIImageView *av = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, statusImage.size.width, statusImage.size.height)];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    av.image = [UIImage imageNamed:@"details_label-no.png"];
    cell.backgroundView = av;

    if (indexPath.section == 0) {
        av.image = [UIImage imageNamed:@"details_label-yes.png"];
    
    } else if(indexPath.section == 1) {
        av.image = [UIImage imageNamed:@"details_label-limited.png"];
    
    } else if(indexPath.section == 2) {
        av.image = [UIImage imageNamed:@"details_label-no.png"];
    } 
    
    return cell;
}


@end
