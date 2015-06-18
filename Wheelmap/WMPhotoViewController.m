//
//  WMPhotoViewController.m
//  Wheelmap
//
//  Created by Andrea Gerlach on 10.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMPhotoViewController.h"
#import "UIImageView+AFNetworking.h"


@interface WMPhotoViewController ()

@end

@implementation WMPhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
              
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
   
    self.scrollPage = 0 ;
    
    self.scrollView.delegate = self;
  
   CGFloat cx = 0;
   CGFloat cy = 0;
    
    for (int i = 0; i < self.imageURLArray.count; i++) {
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height-50)];
        
        CGRect rect = imageView.frame;
        
        rect.size.height = self.view.frame.size.height-50;
        rect.size.width = 320.0f;
        
        rect.origin.y = 0.0f;
        rect.origin.x = 0.0f+cx;
        
        imageView.frame = rect;
        
       //imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
     
        NSString *currentImageURL = [self.imageURLArray objectAtIndex:i];
        [imageView setImageWithURL:[NSURL URLWithString:currentImageURL] placeholderImage:[UIImage imageNamed:@"placeholderImage"]];
        
        [self.scrollView addSubview:imageView];
        
        cx += self.scrollView.frame.size.width;
        cy += self.scrollView.frame.size.height;
        
    }
    
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 331.0f, 320, 36)] ;
    [self.pageControl setCurrentPage:0];
    [self.pageControl addTarget: self action: @selector(pageControlClicked:) forControlEvents: UIControlEventValueChanged] ;
    [self.pageControl setDefersCurrentPageDisplay: YES];
    [self.pageControl setBackgroundColor:[UIColor blackColor]];
  //  [self.view addSubview:self.pageControl];
    
    self.pageControl.numberOfPages = [self.imageURLArray count];
    [self.scrollView setContentSize:CGSizeMake(cx,[self.scrollView bounds].size.height)];
    
    [self.scrollView setPagingEnabled:YES];
    
    UITapGestureRecognizer* tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backButtonPressed:)];
    [self.view addGestureRecognizer:tapGR];
}


- (void)scrollViewDidScroll:(UIScrollView *)sender {

    CGFloat pageWidth = self.scrollView.frame.size.width;
    self.scrollPage = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = self.scrollPage;
    
}


- (void)pageControlClicked:(id)sender {
    
    UIPageControl *thePageControl = (UIPageControl *)sender ;
    
    // we need to scroll to the new index
    [self.scrollView setContentOffset: CGPointMake(self.scrollView.bounds.size.width * thePageControl.currentPage, self.scrollView.contentOffset.y) animated: YES] ;
}

- (void) backButtonPressed:(id) sender {
    [self dismissModalViewControllerAnimated:YES];
}

@end
