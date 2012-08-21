//
//  WCWordCloudView.h
//  WordCloud
//
//  Created by Gal Niv on 7/31/12.
//
//

//#import "WCWord.h"
#import "WCWordCloud.h"

@protocol WCWordCloudViewDelegate;

@interface WCWordCloudView : UIView

@property (nonatomic, retain) id<WCWordCloudViewDelegate> delegate;
@property (nonatomic, readonly) WCWordCloud* cloud;

//@property (nonatomic, retain) NSArray* words;
//@property (nonatomic) double scalingFactor;
//@property (nonatomic) double xShift;
//@property (nonatomic) double yShift;

- (CGSize) sizeThatFitsWidth:(float)width;

@end



@protocol WCWordCloudViewDelegate <NSObject>

@optional

- (void)wordCloudView:(WCWordCloudView *)wcView didTapWord:(WCWord *)word atPoint:(CGPoint)point;

@end