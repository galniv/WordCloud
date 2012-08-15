//
//  WCWordCloudView.m
//  WordCloud
//
//  Created by Gal Niv on 7/31/12.
//
//

#import "WCWordCloudView.h"

@interface WCWordCloudView ()
{
    WCWord *lastTouchedWord;
    CGPoint lastTouchedPoint;
}

@end

@implementation WCWordCloudView

@synthesize delegate = _delegate;
@synthesize words = _words;
@synthesize scalingFactor = _scalingFactor;
@synthesize xShift = _xShift;
@synthesize yShift = _yShift;

- (id)init
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        _scalingFactor = 1;        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _scalingFactor = 1;
    }
    
    return self;
}

- (void) dealloc
{
    _delegate = nil;
    _words = nil;
    
    lastTouchedWord = nil;    
}

- (void)setWords:(NSArray *)wordArray
{
    _words = wordArray;
    [self setNeedsDisplay];
}

- (void)setScalingFactor:(double)scalingFactor
{
    _scalingFactor = scalingFactor;
    [self setNeedsDisplay];
}

- (void)setXShift:(double)xShift
{
    _xShift = xShift;
    [self setNeedsDisplay];
}

- (void)setYShift:(double)yShift
{
    _yShift = yShift;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(c, self.frame);
    
    if (!_words) return;
    
    // set the coordinates for iOS, as seen here:
    // https://developer.apple.com/library/mac/#documentation/graphicsimaging/conceptual/drawingwithquartz2d/dq_text/dq_text.html
    CGContextTranslateCTM(c, 0, self.bounds.size.height);
    CGContextScaleCTM(c, 1, -1);
    
    for (WCWord *word in _words) {
        CGContextSelectFont(c, [word.font.fontName cStringUsingEncoding:NSASCIIStringEncoding], word.font.pointSize * _scalingFactor, kCGEncodingMacRoman);
        CGContextSetFillColorWithColor(c, word.color.CGColor);
        CGContextShowTextAtPoint(c, word.bounds.origin.x * _scalingFactor + _xShift, word.bounds.origin.y * _scalingFactor + _yShift, [word.text cStringUsingEncoding:NSASCIIStringEncoding], word.text.length);
    }
}

// the hitTest selector below ensures that this will only be called when a word has been tapped
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(wordCloudView:didTapWord:atPoint:)]) {
        [self.delegate wordCloudView:self didTapWord:lastTouchedWord atPoint:lastTouchedPoint];
    }
}

// if the point is contained within the bounds of a word, save the point and the relevant word.
// otherwise, return nil to indicate that the point is not contained within this view.
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    for (WCWord *word in _words) {
        if (CGRectContainsPoint(word.bounds, point)) {
            lastTouchedPoint = point;
            lastTouchedWord = word;
            return self;
        }
    }
    
    return nil;
}

@end
