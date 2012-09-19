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

@property (nonatomic) float borderWidth;
@property (nonatomic) UIColor* borderColor;
@property (nonatomic) float cornerRadius;

- (void) highlightWords:(NSArray*)stringWords color:(UIColor*)color;
- (void) clearHighlights;

@end

@protocol WCWordCloudViewDelegate <NSObject>

@optional

- (void) wordCloudView:(WCWordCloudView*)wcView didTapWord:(NSString*)word atRect:(CGRect)rect;

@end