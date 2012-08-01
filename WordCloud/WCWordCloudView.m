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

@synthesize words = _words, scalingFactor, xShift, yShift;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        scalingFactor = 1;
    }
    
    return self;
}

- (void)setWords:(NSArray *)wordArray
{
    _words = wordArray;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(c, self.frame);
    
    // set the coordinates for iOS, as seen here https://developer.apple.com/library/mac/#documentation/graphicsimaging/conceptual/drawingwithquartz2d/dq_text/dq_text.html
    CGContextTranslateCTM(c, 0, self.bounds.size.height);
    CGContextScaleCTM(c, 1, -1);
    
    if (!_words) return;
    
    WCWord *word;
    
    for (int i = 0; i < _words.count; i++) {
        word = (WCWord *)[_words objectAtIndex:i];
        CGContextSelectFont(c, [word.font.fontName cStringUsingEncoding:NSASCIIStringEncoding], word.font.pointSize * scalingFactor, kCGEncodingMacRoman);
        CGContextSetFillColorWithColor(c, word.color);
        CGContextShowTextAtPoint(c, word.bounds.origin.x * scalingFactor + xShift, word.bounds.origin.y * scalingFactor + yShift, [word.text cStringUsingEncoding:NSASCIIStringEncoding], word.text.length);
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
    WCWord *word;
    
    for (int i = 0; i < _words.count; i++) {
        word = (WCWord *)[_words objectAtIndex:i];
        if (CGRectContainsPoint(word.bounds, point)) {
            lastTouchedPoint = point;
            lastTouchedWord = word;
            return self;
        }
    }
    
    return nil;
}

@end
