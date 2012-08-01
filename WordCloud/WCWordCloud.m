//
//  WCWordCloud.m
//  WordCloud
//
//  Created by Gal Niv on 7/15/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "WCWordCloud.h"

@interface WCWordCloud ()
{
    WCWordCloudView *wcView;
    NSArray *arrangedWords;
    double scalingFactor;
    double xShift;
    double yShift;
}

- (BOOL)rectIntersectsWordArray:(CGRect)rect array:(NSArray *)wordArray;
- (CGColorRef)CGColorRefFromUIColor:(UIColor*)newColor;
- (CGRect)addRectBorder:(CGRect)rect border:(int)borderSize;

@end

@implementation WCWordCloud

@synthesize maxNumberOfWords, minFontSize, maxFontSize, font, minimumWordLength, lowCountColor, highCountColor, wordBorderSize;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // defaults
        maxNumberOfWords = 0;
        minimumWordLength = 3;
        
        minFontSize = 10;
        maxFontSize = 100;
        font = [UIFont systemFontOfSize:minFontSize];
        
        lowCountColor = [UIColor blackColor];
        highCountColor = [UIColor blackColor];
        
        scalingFactor = 1;
        xShift = 0;
        yShift = 0;
        
        wordBorderSize = 2;
    }
    return self;
}

- (void)dealloc
{
    font = nil;
    lowCountColor = nil;
    highCountColor = nil;
}

- (void)loadView
{
    [super loadView];
    
    wcView = [[WCWordCloudView alloc] init];
    wcView.delegate = self;
    wcView.words = arrangedWords;
    wcView.scalingFactor = scalingFactor;
    wcView.xShift = xShift;
    wcView.yShift = yShift;
    
    [self.view addSubview:wcView];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    wcView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)createWordCloud:(NSString *)wordString delimiter:(NSString *)delimiter
{
    [self createWordCloud:[wordString componentsSeparatedByString:delimiter]];
}

- (void)createWordCloud:(NSArray *)words
{
    if (!words || words.count == 0) return;
    
    __block NSMutableDictionary *wordCounts = [[NSMutableDictionary alloc] init];
    
    // count the number of occurences of each word
    [words enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         // trim non-letter characters and convert to lower case
         obj = [[((NSString *)obj) stringByTrimmingCharactersInSet:[[NSCharacterSet letterCharacterSet] invertedSet]] lowercaseString];
         
         // ignore all words shorter than the minimum word length
         if (((NSString *)obj).length > minimumWordLength) {
             if ([wordCounts objectForKey:obj] == nil) {
                 [wordCounts setValue:[[WCWord alloc] initWithWord:obj count:1] forKey:obj];
             }
             else {
                 [(WCWord *)[wordCounts valueForKey:obj] increaseCount];
             }
         }
     }];
    
    // sort by number of occurences
    NSMutableArray *sortedWords = [NSMutableArray arrayWithArray:[[wordCounts allValues] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"count" ascending:FALSE]]]];
    
    // normalize font sizes based on the word with the highest number of occurances
    float fontSizePerOccurance = (maxFontSize - minFontSize) / ((WCWord *)[sortedWords objectAtIndex:0]).count;
    
    // prepare colors for interpolation
    const CGFloat* lowCountColorComponents = CGColorGetComponents([self CGColorRefFromUIColor:lowCountColor]);
    const CGFloat* highCountColorComponents = CGColorGetComponents([self CGColorRefFromUIColor:highCountColor]);
    
    float rColorPerOccurance = (highCountColorComponents[0] - lowCountColorComponents[0]) / ((WCWord *)[sortedWords objectAtIndex:0]).count;
    float gColorPerOccurance = (highCountColorComponents[1] - lowCountColorComponents[1]) / ((WCWord *)[sortedWords objectAtIndex:0]).count;
    float bColorPerOccurance = (highCountColorComponents[2] - lowCountColorComponents[2]) / ((WCWord *)[sortedWords objectAtIndex:0]).count;
    float aColorPerOccurance = (CGColorGetAlpha(highCountColor.CGColor) - CGColorGetAlpha(lowCountColor.CGColor)) / ((WCWord *)[sortedWords objectAtIndex:0]).count;
    
    WCWord *word;
    CGSize wordSize;
    
    double step = 2;
    double aspectRatio = self.view.frame.size.width / self.view.frame.size.height;
    int xPos, yPos;
    
    // statistics for later calculation of scaling factor
    int minX = INT_MAX;
    int maxX = INT_MIN;
    int minY = INT_MAX;
    int maxY = INT_MIN;
    
    NSMutableArray *alreadyPlaced = [[NSMutableArray alloc] initWithCapacity:sortedWords.count];
    
    int wordLimit = (maxNumberOfWords > 0 ? maxNumberOfWords : sortedWords.count);
    
    for (int i = 0; i < wordLimit; i++) {
        double angle = 10 * random();
        double radius = 0;
        
        word = [sortedWords objectAtIndex:i];
        word.font = [font fontWithSize:minFontSize + (fontSizePerOccurance * word.count)];
        wordSize = [word.text sizeWithFont:word.font];
        word.bounds = CGRectMake(arc4random_uniform(10) + (self.view.frame.size.width / 2), arc4random_uniform(10) + (self.view.frame.size.height / 2), wordSize.width, wordSize.height);
        
        word.color = [UIColor colorWithRed:lowCountColorComponents[0] + (rColorPerOccurance * word.count)
                                     green:lowCountColorComponents[1] + (gColorPerOccurance * word.count)
                                      blue:lowCountColorComponents[2] + (bColorPerOccurance * word.count)
                                     alpha:CGColorGetAlpha(lowCountColor.CGColor) + (aColorPerOccurance * word.count)].CGColor;
        
        // move word until there are no collisions with previously placed words
        // adapted from https://github.com/lucaong/jQCloud
        while ([self rectIntersectsWordArray:[self addRectBorder:word.bounds border:wordBorderSize] array:alreadyPlaced]) {
            radius += step;
            angle += (i % 2 == 0 ? 1 : -1) * step;
            
            xPos = (self.view.frame.size.width / 2) - (wordSize.width / 2) + (radius * cos(angle)) * aspectRatio;
            yPos = (self.view.frame.size.height / 2) + radius * sin(angle) - (wordSize.height / 2);
            
            word.bounds = CGRectMake(xPos, yPos, wordSize.width, wordSize.height);
        }
        
        if (minX > word.bounds.origin.x) minX = word.bounds.origin.x;
        if (minY > word.bounds.origin.y) minY = word.bounds.origin.y;
        if (maxX < word.bounds.origin.x + wordSize.width) maxX = word.bounds.origin.x + wordSize.width;
        if (maxY < word.bounds.origin.y + wordSize.height) maxY = word.bounds.origin.y + wordSize.height;
        
        [alreadyPlaced addObject:word];
    }
    
    arrangedWords = [NSArray arrayWithArray:sortedWords];
    
    scalingFactor = 1;
    
    // scale down if necessary
    if (maxX - minX > self.view.frame.size.width) {
        scalingFactor = self.view.frame.size.width / (double)(maxX - minX);
        
        // if we are here, then words are larger than the view, and either minX is negative or maxX is larger than the width.
        // calculate the amount by which to shift all words so that they fit in the view.
        if (minX < 0) xShift = minX * scalingFactor * -1;
        else xShift = (self.view.frame.size.width - maxX) * scalingFactor;
    }
    
    if (maxY - minY > self.view.frame.size.height) {
        double newScalingFactor = self.view.frame.size.height / (double)(maxY - minY);
        
        // if we've already scaled down in the X dimension, only apply the new scale if it is smaller
        if (scalingFactor < 1 && newScalingFactor < scalingFactor) {
            scalingFactor = newScalingFactor;
        }
        
        // if we are here, then words are larger than the view, and either minX is negative or maxX is larger than the width.
        // calculate the amount by which to shift all words so that they fit in the view.
        if (minY < 0) yShift = minY * scalingFactor * -1;
        else yShift = (self.view.frame.size.height - maxY) * scalingFactor;
    }
    
    wcView.words = arrangedWords;
    wcView.scalingFactor = scalingFactor;
    wcView.xShift = xShift;
    wcView.yShift = yShift;
}

- (BOOL)rectIntersectsWordArray:(CGRect)rect array:(NSArray *)wordArray
{
    WCWord *word;
    for (int i = 0; i < wordArray.count; i++) {
        word = (WCWord *)[wordArray objectAtIndex:i];
        
        if (CGRectIntersectsRect(rect, word.bounds)) return TRUE;
    }
    
    return FALSE;
}

- (CGRect)addRectBorder:(CGRect)rect border:(int)borderSize
{
    return CGRectMake(rect.origin.x - borderSize, rect.origin.y - borderSize, rect.size.width + (borderSize * 2), rect.size.height + (borderSize * 2));
}

// hack to get the correct CGColors from ANY UIColor, even in a non-RGB color space (greyscale, etc)
// borrowed from http://stackoverflow.com/questions/4155642/how-to-get-color-components-of-a-cgcolor-correctly
- (CGColorRef)CGColorRefFromUIColor:(UIColor*)newColor
{
    CGFloat components[4] = {0.0, 0.0, 0.0, 0.0};
    [newColor getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];
    CGColorRef newRGB = CGColorCreate(CGColorSpaceCreateDeviceRGB(), components);
    return newRGB;
}

// WCWordCloudViewDelegate
- (void)wordCloudView:(WCWordCloudView *)wcView didTapWord:(WCWord *)word atPoint:(CGPoint)point
{
    if ([self.delegate respondsToSelector:@selector(wordCloud:didTapWord:atPoint:)]) {
        [self.delegate wordCloud:self didTapWord:word.text atPoint:point];
    }
}

@end
