//
//  WCWordCloudViewController.h
//  elements
//
//  Created by Gal Niv on 8/7/12.
//  Copyright (c) 2012 exploros. All rights reserved.
//

#import "WCWordCloudView.h"
#import "WCWordCloud.h"

@protocol WCWordCloudViewControllerDelegate;

@interface WCWordCloudViewController : UIViewController <WCWordCloudViewDelegate, WCWordCloudDelegate>

@property (nonatomic, retain) id<WCWordCloudViewControllerDelegate> delegate;

@property (nonatomic, readonly) WCWordCloud *wordCloud;

@end


@protocol WCWordCloudViewControllerDelegate <NSObject>

@optional

- (void)wordCloud:(WCWordCloud *)wc didTapWord:(NSString *)word atPoint:(CGPoint)point;

@end