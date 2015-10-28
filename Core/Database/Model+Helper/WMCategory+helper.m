//
//  WMCategory+Helper.h
//  
//
//  Created by Hans Seiffert on 20.10.15.
//
//

#import "WMCategory+Helper.h"

@implementation WMCategory (Helper)

- (NSArray *)sortedNodeTypes {
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:K_DB_KEY_CATEGORY_LOCALIZED_NAME ascending:YES];
	return [self.nodeType sortedArrayUsingDescriptors:@[sortDescriptor]];
}

@end
