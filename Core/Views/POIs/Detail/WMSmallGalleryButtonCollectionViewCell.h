//
//  WMSmallGalleryButtonCollectionViewCell.h
//  Wheelmap
//
//  Created by SMF on 16.11.15.
//  Copyright © 2015 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMSmallGalleryButtonCollectionViewCell : UICollectionViewCell

@property (nonatomic) id<WMSmallGalleryButtonCollectionViewCellDelegate>	delegate;

@property (weak, nonatomic) IBOutlet UIButton *								button;

@end
