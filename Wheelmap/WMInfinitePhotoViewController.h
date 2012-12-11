//
//  WMInfinitePhotoViewController.h
//  Wheelmap
//
//  Created by Andrea Gerlach on 11.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfiniteGallery.h"

@interface WMInfinitePhotoViewController : WMViewController <InfiniteGalleryDataSource, InfiniteGalleryDelegate>

@property (nonatomic, strong) NSMutableArray *imageURLArray;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet InfiniteGallery *infiniteGallery;

@property (assign) int tappedImage;

@end
