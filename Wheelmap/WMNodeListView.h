//
//  WMNodeListView.h
//  Wheelmap
//
//  Created by Dorian Roy on 07.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocation, Node;

@protocol WMNodeListView;


@protocol WMNodeListDataSource <NSObject>

- (NSArray*) nodeList;

@end


@protocol WMNodeListDelegate <NSObject>

- (void) nodeListView:(id<WMNodeListView>)nodeListView didSelectDetailsForNode:(Node*)node;

@optional
- (void) nodeListView:(id<WMNodeListView>)nodeListView didSelectNode:(Node*)node;

@end


@protocol WMNodeListView <NSObject>

@property (nonatomic, weak) IBOutlet id<WMNodeListDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id<WMNodeListDelegate> delegate;

- (void) nodeListDidChange;
- (void) selectNode:(Node*)node;

@end
