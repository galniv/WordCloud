//
//  WCWordCloudView.h
//  WordCloud
//
//  Created by Gal Niv on 7/31/12.
//
//

#import "WCWordCloud.h"

@protocol WCWordCloudViewDelegate;

@interface WCWordCloudView : UIView

@property (nonatomic, retain) id<WCWordCloudViewDelegate> delegate;
@property (nonatomic, readonly) WCWordCloud* cloud;

- (CGSize) sizeThatFitsWidth:(float)width;

@end

@protocol WCWordCloudViewDelegate <NSObject>

@optional

- (void)wordCloudView:(WCWordCloudView *)wcView didTapWord:(WCWord *)word atPoint:(CGPoint)point;

@end