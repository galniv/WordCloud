//
//  WCWordCloudView.m
//  WordCloud
//
//  Created by Gal Niv on 7/31/12.
//
//

#import <QuartzCore/QuartzCore.h>

#import "WCWordCloudView.h"

@interface WCWordCloudView () <WCWordCloudDelegate>
{
    NSMutableDictionary* wordRects;    
    NSString* lastTouchedWord;
}

@property (nonatomic, retain, readonly) NSArray* words;
@property (nonatomic, readonly) double scalingFactor;
@property (nonatomic, readonly) double xShift;
@property (nonatomic, readonly) double yShift;

@end

@implementation WCWordCloudView

- (void) baseInit
{
    //self.layer.masksToBounds = TRUE;
    //self.layer.shouldRasterize = YES; // test
    
    self.backgroundColor = [UIColor clearColor];
    _scalingFactor = 1;
    
    _cloud = [[WCWordCloud alloc] init];
    _cloud.delegate = self;
}

- (id) init
{
    if (self = [super init])
    {
        [self baseInit];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self baseInit];
    }    
    return self;
}

- (void) dealloc
{
    _cloud = nil;    
    _words = nil;
    
    lastTouchedWord = nil;
    wordRects = nil;
}

#pragma mark - view lifecycle

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    if (true == CGSizeEqualToSize(self.frame.size, self.cloud.cloudSize)) return;
    self.cloud.cloudSize = self.frame.size;
}

#pragma mark - WCWordCloudDelegate

- (void) wordCloudDidGenerateCloud:(WCWordCloud*)wc sortedWordArray:(NSArray*)words scalingFactor:(double)scalingFactor xShift:(double)xShift yShift:(double)yShift
{
    _words = words;
    _scalingFactor = scalingFactor;
    _xShift = xShift;
    _yShift = yShift;
    
    wordRects = [[NSMutableDictionary alloc] initWithCapacity:self.words.count];
    for (WCWord* word in self.words)
    {
        float w = word.bounds.size.width * self.scalingFactor;
        float h = word.bounds.size.height * self.scalingFactor;
        float x = self.xShift + word.bounds.origin.x * self.scalingFactor;
        float y =  self.bounds.size.height - (self.yShift + word.bounds.origin.y * self.scalingFactor) - h;
        [wordRects setObject:[NSValue valueWithCGRect:CGRectMake(x, y, w, h)] forKey:word.text];
    }
    
    [self setNeedsDisplay];
}

#pragma mark - private

- (void) drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(c, self.frame);
    
    if (!self.words.count) return;
    
    // set the coordinates for iOS, as seen here:
    // https://developer.apple.com/library/mac/#documentation/graphicsimaging/conceptual/drawingwithquartz2d/dq_text/dq_text.html
    CGContextTranslateCTM(c, 0, self.bounds.size.height);
    CGContextScaleCTM(c, 1, -1);
    
    for (WCWord* word in self.words)
    {
        CGContextSelectFont(c, [word.font.fontName cStringUsingEncoding:NSASCIIStringEncoding], word.font.pointSize * self.scalingFactor, kCGEncodingMacRoman);
        CGContextSetFillColorWithColor(c, word.color.CGColor);
        CGContextShowTextAtPoint(c, self.xShift + word.bounds.origin.x * self.scalingFactor, self.yShift + word.bounds.origin.y * self.scalingFactor, [word.text cStringUsingEncoding:NSASCIIStringEncoding], word.text.length);
    }
}

// the hitTest selector below ensures that this will only be called when a word has been tapped
- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    if ([self.delegate respondsToSelector:@selector(wordCloudView:didTapWord:atRect:)])
    {
        NSValue* value = [wordRects objectForKey:lastTouchedWord];        
        [self.delegate wordCloudView:self didTapWord:lastTouchedWord atRect:value.CGRectValue];
    }
}

// if the point is contained within the bounds of a word, save the point and the relevant word.
// otherwise, return nil to indicate that the point is not contained within this view.
- (UIView*) hitTest:(CGPoint)point withEvent:(UIEvent*)event
{
    for (NSString* word in wordRects.allKeys)
    {
        CGRect rect = [[wordRects objectForKey:word] CGRectValue];
        if (CGRectContainsPoint(rect, point))
        {
            lastTouchedWord = word;
            return self;
        }
    }
    
    return nil;
}

@end
