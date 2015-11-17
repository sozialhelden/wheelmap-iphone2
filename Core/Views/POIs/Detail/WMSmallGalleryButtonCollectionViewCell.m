//
//  WMSmallGalleryButtonCollectionViewCell.m
//  Wheelmap
//
//  Created by SMF on 16.11.15.
//  Copyright © 2015 Sozialhelden e.V. All rights reserved.
//

#import "WMSmallGalleryButtonCollectionViewCell.h"

@implementation WMSmallGalleryButtonCollectionViewCell

- (IBAction)didPressCameraButton:(id)sender {
	if (self.delegate != nil) {
		[self.delegate didPressCameraButton];
	}
}

@end
