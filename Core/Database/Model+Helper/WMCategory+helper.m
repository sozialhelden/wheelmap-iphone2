//
//  WMCategory+Helper.h
//  
//
//  Created by Hans Seiffert on 20.10.15.
//
//

#import "WMCategory+Helper.h"
#import <objc/runtime.h>

@implementation WMCategory (Helper)

#pragma mark - Custom variables
// Check e.g. http://nshipster.com/associated-objects/ which explains AssociatedObjects. We use them to add the selected property to this category.

- (void)setSelected:(NSNumber *)selected {
	objc_setAssociatedObject(self, @selector(selected), selected, OBJC_ASSOCIATION_RETAIN);
}

- (NSNumber *)selected {
	NSNumber *selected = objc_getAssociatedObject(self, @selector(selected));
	if (selected == nil) {
		return @(YES);
	}
	return selected;
}

#pragma mark - 
- (NSArray *)sortedNodeTypes {
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:K_DB_KEY_CATEGORY_LOCALIZED_NAME ascending:YES];
	return [self.nodeType sortedArrayUsingDescriptors:@[sortDescriptor]];
}

@end
