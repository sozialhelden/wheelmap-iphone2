//
//  WMPhotoViewController.h
//  Wheelmap
//
//  Created by Andrea Gerlach on 10.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMPhotoViewController : WMViewController <UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *imageURLArray;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (assign) double scrollPage;
@property (assign) int tappedImage;

@end
