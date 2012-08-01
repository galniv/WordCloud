//
//  WCWordCloudView.h
//  WordCloud
//
//  Created by Gal Niv on 7/31/12.
//
//

#import "WCWord.h"

@protocol WCWordCloudViewDelegate;

@interface WCWordCloudView : UIView

@property (nonatomic, retain) id<WCWordCloudViewDelegate> delegate;

@property (nonatomic, retain) NSArray *words;
@property (nonatomic) double scalingFactor;
@property (nonatomic) double xShift;
@property (nonatomic) double yShift;

@end



@protocol WCWordCloudViewDelegate <NSObject>

@optional

- (void)wordCloudView:(WCWordCloudView *)wcView didTapWord:(WCWord *)word atPoint:(CGPoint)point;

@end