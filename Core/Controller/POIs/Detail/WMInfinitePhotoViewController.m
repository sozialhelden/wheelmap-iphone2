//
//  WMInfinitePhotoViewController.m
//  Wheelmap
//
//  Created by Andrea Gerlach on 11.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMInfinitePhotoViewController.h"
#import "InfiniteGallery.h"
#import "UIImageView+AFNetworking.h"


@interface WMInfinitePhotoViewController ()

@end

@implementation WMInfinitePhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.imageURLArray = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.containerView.backgroundColor = [UIColor wmGreyColor];
    
    self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    
    [self.closeButton setTitle:NSLocalizedString(@"Ready", nil) forState:UIControlStateNormal];
    
    self.infiniteGallery = [[InfiniteGallery alloc] initWithFrame:self.galleryView.bounds];
    
    self.infiniteGallery.dataSource = self;
    self.infiniteGallery.delegate = self;
    
    [self.galleryView addSubview:self.infiniteGallery];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.infiniteGallery gotoPageNumber:self.tappedImage];
}

#pragma mark InfiniteGallery

-(long)numberOfPagesForGallery:(InfiniteGallery *)g {
    
    return self.imageURLArray.count;
}

-(UIView*)viewForGallery:(InfiniteGallery *)g pageNum:(long)pageNum pagesize:(CGSize)size {
    
    NSString *currentImageURL = [self.imageURLArray objectAtIndex:pageNum];
    UIImageView *imageView = [UIImageView new];
    [imageView setImageWithURL:[NSURL URLWithString:currentImageURL] placeholderImage:[UIImage imageNamed:@"placeholderImage"]];
    imageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    return imageView;
}

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES];
    
}
@end