//
//  WMStandardButton.m
//  
//
//  Created by Hans Seiffert on 19.10.15.
//
//

#import "WMStandardButton.h"

@implementation WMStandardButton

- (instancetype)init {
	self = [super init];

	if (self != nil) {
		[self initStandardValues];
	}

	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];

	[self initStandardValues];
}

- (void)initStandardValues {
	self.backgroundColor = UIColor.wmNavigationBackgroundColor;
	self.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
}

@end
