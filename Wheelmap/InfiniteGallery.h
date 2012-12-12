//
//  InfiniteGallery.h
//  SuperTextView
//
//  Created by Stephen O'Connor on 10/26/11.
//  Copyright (c) 2011 Smart Mobile Factory GmbH. All rights reserved.
//  

// based on http://iphonedevelopertips.com/user-interface/creating-circular-and-infinite-uiscrollviews.html

#import <UIKit/UIKit.h>


@class InfiniteGallery;  // have to declare that a class exists that will be declared and implemented, so that the compiler knows it will exist.  This way you can write the dataSource and delegate protocols before the class declaration.


@protocol InfiniteGalleryDataSource <NSObject>

- (UIView*)viewForGallery:(InfiniteGallery*)g pageNum:(int)pageNum pagesize:(CGSize)size;  // uses gallery frame size to create itself
- (int)numberOfPagesForGallery:(InfiniteGallery*)g;

@end

@protocol InfiniteGalleryDelegate <NSObject>

-(void)gallery:(InfiniteGallery*)g didTurnToPage:(int)page totalPages:(int)total;

@end


@interface InfiniteGallery : UIView<UIScrollViewDelegate, InfiniteGalleryDataSource>

@property (nonatomic, retain) id<InfiniteGalleryDataSource> dataSource;
@property (nonatomic, retain) id<InfiniteGalleryDelegate> delegate;

@property (nonatomic, readonly) UIView *currentView;
@property (nonatomic, readonly) UIView *nextView;
@property (nonatomic, readonly) UIView *prevView;

@property BOOL wrapsAround;

- (void)gotoPageNumber:(int)pageNum;
- (UIColor*)bgcolor;
- (void)setBgcolor:(UIColor*)color;
- (void)reloadData;

@end


