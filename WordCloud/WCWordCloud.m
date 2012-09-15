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
    NSMutableArray* sortedWords;
    NSMutableDictionary* wordCounts;
    WCWord* topWord;
    
    CGFloat lowCountColorComponents[4];
    CGFloat highCountColorComponents[4];
    
    //NSCharacterSet* nonLetterCharacterSet;
}

- (void) incrementCount:(NSString*)word;
- (void) decrementCount:(NSString*)word;
- (void) setNeedsGenerateCloud;
- (void) generateCloud;

- (CGColorRef) CGColorRefFromUIColor:(UIColor*)color CF_RETURNS_RETAINED;

@end

@implementation WCWordCloud

- (id) init
{
    if (self = [super init])
    {
        // defaults
        _maxNumberOfWords = 0;
        _minimumWordLength = 3;
        
        _minFontSize = 10;
        _maxFontSize = 100;
        _font = [UIFont systemFontOfSize:self.minFontSize];
        
        _wordBorderSize = 2;
        
        _cloudSize = CGSizeZero;
                
        self.lowCountColor = [UIColor blackColor];
        self.highCountColor = [UIColor blackColor];
        
        wordCounts = [[NSMutableDictionary alloc] init];        
        //nonLetterCharacterSet = [[NSCharacterSet letterCharacterSet] invertedSet];
    }
    return self;
}

- (void) dealloc
{
    _font = nil;
    
    _lowCountColor = nil;
    _highCountColor = nil;
    
    sortedWords = nil;
    wordCounts = nil;
    topWord = nil;
    
    //delete(lowCountColorComponents);
    //delete(highCountColorComponents);
    
    //nonLetterCharacterSet = nil;
}

- (void) rebuild:(NSArray*)words
{
    [self removeAllWords];
    [self addWords:words];
}

- (void) addWords:(NSString*)wordString delimiter:(NSString*)delimiter
{
    if (!wordString.length) return;
    [self addWords:[wordString componentsSeparatedByString:delimiter]];
}

- (void) addWords:(NSArray*)words
{
    for (NSString* word in words)
    {
        [self addWord:word];
    }
}

- (void) addWord:(NSString*)word
{
    [self incrementCount:word];
}

- (void) removeWords:(NSArray*)words
{
    for (NSString* word in words)
    {
        [self removeWord:word];
    }
}

- (void) removeWord:(NSString*)word
{
    [self decrementCount:word];
}

- (void) removeAllWords
{
    [wordCounts removeAllObjects];
    [sortedWords removeAllObjects];
    topWord = nil;
    
    [self setNeedsGenerateCloud];
}

// private
- (void) incrementCount:(NSString*)word
{
    if (!word.length) return;
    // trim non-letter characters and convert to lower case
    NSString* cleanWord = [[word trim] lowercaseString]; //[[word stringByTrimmingCharactersInSet:nonLetterCharacterSet] lowercaseString];
    // ignore all words shorter than the minimum word length
    if (cleanWord.length < self.minimumWordLength) return;
        
    WCWord* wcword = [wordCounts valueForKey:cleanWord];    
    if (!wcword)
    {
        wcword = [[WCWord alloc] initWithWord:cleanWord count:0];
        [wordCounts setValue:wcword forKey:cleanWord];
    }
    [wcword incrementCount];
    
    [self sortWords];
    
    if (!topWord || topWord.count < wcword.count)
    {
        topWord = wcword;
    }
    
    [self setNeedsGenerateCloud];
}

- (void) decrementCount:(NSString*)word
{
    if (!word.length) return;
    // trim non-letter characters and convert to lower case
    NSString* cleanWord = [[word trim] lowercaseString]; //[[word stringByTrimmingCharactersInSet:nonLetterCharacterSet] lowercaseString];
    
    WCWord* wcword = [wordCounts valueForKey:cleanWord];
    if (!wcword) return;    
    [wcword decrementCount];
    
    [self sortWords];
    
    if (topWord == wcword)
    {
        // find new top word
        for (WCWord* word in wordCounts.allValues)
        {
            if (word.count > topWord.count) topWord = word;
        }
    }
    
    [self setNeedsGenerateCloud];    
}

- (void) sortWords
{
    sortedWords = [NSMutableArray arrayWithArray:[[wordCounts allValues] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"count" ascending:FALSE]]]];
}

- (void) setNeedsGenerateCloud
{
    @synchronized(self)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(generateCloud) object:nil];
        [self performSelector:@selector(generateCloud) withObject:nil afterDelay:0.1f];
    }
}

// sorts words if needed, and lays them out
- (void) generateCloud
{
    double scalingFactor = 1;
    double xShift = 0;
    double yShift = 0;
    
    if (!wordCounts.count) return;
    if (!topWord) return;
    if (!topWord.count) return;
    if (true == CGSizeEqualToSize(self.cloudSize, CGSizeZero)) return;
    
    double step = 2;
    double aspectRatio = self.cloudSize.width / self.cloudSize.height;

    // normalize font sizes based on the word with the highest number of occurances
    float fontSizePerOccurance = (self.maxFontSize - self.minFontSize) / topWord.count;
    
    // prepare colors for interpolation
    float rColorPerOccurance = (highCountColorComponents[0] - lowCountColorComponents[0]) / topWord.count;
    float gColorPerOccurance = (highCountColorComponents[1] - lowCountColorComponents[1]) / topWord.count;
    float bColorPerOccurance = (highCountColorComponents[2] - lowCountColorComponents[2]) / topWord.count;
    float aColorPerOccurance = (highCountColorComponents[3] - lowCountColorComponents[3]) / topWord.count;

    // statistics for later calculation of scaling factor
    int minX = INT_MAX;
    int maxX = INT_MIN;
    int minY = INT_MAX;
    int maxY = INT_MIN;
    
    int wordLimit = self.maxNumberOfWords ? self.maxNumberOfWords : sortedWords.count;    
    for (int index=0; index < wordLimit; index++)
    {
        WCWord* word = [sortedWords objectAtIndex:index];
        
        // only recalculate the word's size if its count has changed, or if the highest count has increased
        // (thus increasing the size per occurance)
        //if (word.countChanged || highestWordCountChanged) {
            word.font = [self.font fontWithSize:self.minFontSize + (fontSizePerOccurance * word.count)];
                        
            word.color = [UIColor colorWithRed:lowCountColorComponents[0] + (rColorPerOccurance * word.count)
                                         green:lowCountColorComponents[1] + (gColorPerOccurance * word.count)
                                          blue:lowCountColorComponents[2] + (bColorPerOccurance * word.count)
                                         alpha:lowCountColorComponents[3] + (aColorPerOccurance * word.count)];
            
            //word.countChanged = FALSE;
        //}
        
        CGSize wordSize = [word.text sizeWithFont:word.font];
        wordSize.height += (self.wordBorderSize * 2);
        wordSize.width += (self.wordBorderSize * 2);
        
        float horizCenter = (self.cloudSize.width - wordSize.width)/2;
        float vertCenter = (self.cloudSize.height - wordSize.height)/2;
        
        word.bounds = CGRectMake(arc4random_uniform(10) + horizCenter, arc4random_uniform(10) + vertCenter, wordSize.width, wordSize.height);
        
        BOOL intersects = FALSE;
        double angleStep = (index % 2 == 0 ? 1 : -1) * step;
        double radius = 0;
        double angle = 10 * random();
        // move word until there are no collisions with previously placed words
        // adapted from https://github.com/lucaong/jQCloud
        do
        {
            for (int otherIndex=0; otherIndex < index; otherIndex++)
            {
                intersects = CGRectIntersectsRect(word.bounds, ((WCWord*)[sortedWords objectAtIndex:otherIndex]).bounds);
                
                // if the current word intersects with word that has already been placed, move the current word, and
                // recheck against all already-placed words
                if (intersects)
                {
                    radius += step;
                    angle += angleStep;
                    
                    int xPos = horizCenter + (radius * cos(angle)) * aspectRatio;
                    int yPos = vertCenter + radius * sin(angle);
                    
                    word.bounds = CGRectMake(xPos, yPos, wordSize.width, wordSize.height);
                    
                    break;
                }
            }
        } while (intersects);
        
        if (minX > word.bounds.origin.x) minX = word.bounds.origin.x;
        if (minY > word.bounds.origin.y) minY = word.bounds.origin.y;
        if (maxX < word.bounds.origin.x + wordSize.width) maxX = word.bounds.origin.x + wordSize.width;
        if (maxY < word.bounds.origin.y + wordSize.height) maxY = word.bounds.origin.y + wordSize.height;
    }
        
    // scale down if necessary
    if (maxX - minX > self.cloudSize.width)
    {
        scalingFactor = self.cloudSize.width / (double)(maxX - minX);
        
        // if we are here, then words are larger than the view, and either minX is negative or maxX is larger than the width.
        // calculate the amount by which to shift all words so that they fit in the view.
        if (minX < 0) xShift = minX * scalingFactor * -1;
        else xShift = (self.cloudSize.width - maxX) * scalingFactor;
    }
    
    if (maxY - minY > self.cloudSize.height)
    {
        double newScalingFactor = self.cloudSize.height / (double)(maxY - minY);
        
        // if we've already scaled down in the X dimension, only apply the new scale if it is smaller
        if (scalingFactor < 1 && newScalingFactor < scalingFactor)
        {
            scalingFactor = newScalingFactor;
        }
        
        // if we are here, then words are larger than the view, and either minX is negative or maxX is larger than the width.
        // calculate the amount by which to shift all words so that they fit in the view.
        if (minY < 0) yShift = minY * scalingFactor * -1;
        else yShift = (self.cloudSize.height - maxY) * scalingFactor;
    }
    
    if ([self.delegate respondsToSelector:@selector(wordCloudDidGenerateCloud:sortedWordArray:scalingFactor:xShift:yShift:)])
    {
        [self.delegate wordCloudDidGenerateCloud:self sortedWordArray:sortedWords scalingFactor:scalingFactor xShift:xShift yShift:yShift];
    }
}

#pragma mark - accessors

- (void) setCloudSize:(CGSize)cloudSize
{
    if (true == CGSizeEqualToSize(cloudSize, self.cloudSize)) return;
    _cloudSize = cloudSize;
    
    [self setNeedsGenerateCloud];
}

- (void) setFont:(UIFont*)font
{
    if (font == self.font) return;    
    _font = font;
    
    [self setNeedsGenerateCloud];
}

- (void) setMinFontSize:(int)minFontSize
{
    if (minFontSize == self.minFontSize) return;
    _minFontSize = minFontSize;
    
    [self setNeedsGenerateCloud];
}

- (void) setMaxFontSize:(int)maxFontSize
{
    if (maxFontSize == self.maxFontSize) return;
    _maxFontSize = maxFontSize;
    
    [self setNeedsGenerateCloud];
}

- (void) setWordBorderSize:(int)wordBorderSize
{
    if (wordBorderSize == self.wordBorderSize) return;
    _wordBorderSize = wordBorderSize;
    
    [self setNeedsGenerateCloud];
}

- (void) setLowCountColor:(UIColor*)color
{
    if (color == self.lowCountColor) return;
    _lowCountColor = color;
        
    CGColorRef colorRef = [self CGColorRefFromUIColor:color];
    const CGFloat* components = CGColorGetComponents(colorRef);
    lowCountColorComponents[0] = components[0];
    lowCountColorComponents[1] = components[1];
    lowCountColorComponents[2] = components[2];
    lowCountColorComponents[3] = CGColorGetAlpha(color.CGColor);
    CGColorRelease(colorRef);
    
    [self setNeedsGenerateCloud];
}

- (void) setHighCountColor:(UIColor*)color
{
    if (color == self.highCountColor) return;
    _highCountColor = color;
        
    CGColorRef colorRef = [self CGColorRefFromUIColor:color];
    const CGFloat* components = CGColorGetComponents(colorRef);
    highCountColorComponents[0] = components[0];
    highCountColorComponents[1] = components[1];
    highCountColorComponents[2] = components[2];
    highCountColorComponents[3] = CGColorGetAlpha(color.CGColor);
    CGColorRelease(colorRef);
    
    [self setNeedsGenerateCloud];
}

- (void) setMaxNumberOfWords:(int)maxNumberOfWords
{
    if (maxNumberOfWords == self.maxNumberOfWords) return;
    
    _maxFontSize = maxNumberOfWords;
    [self setNeedsGenerateCloud];
}


- (void) setMinimumWordLength:(int)minimumWordLength
{
    if (minimumWordLength == self.minimumWordLength) return;    
    _minimumWordLength = minimumWordLength;
    
    [self rebuild:[wordCounts.allKeys copy]];
}


#pragma mark - util

// hack to get the correct CGColors from ANY UIColor, even in a non-RGB color space (greyscale, etc)
// borrowed from http://stackoverflow.com/questions/4155642/how-to-get-color-components-of-a-cgcolor-correctly
- (CGColorRef) CGColorRefFromUIColor:(UIColor*)color
{
    CGFloat components[4] = {0.0, 0.0, 0.0, 0.0};
    [color getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorRef = CGColorCreate(colorSpaceRef, components);    
    CGColorSpaceRelease(colorSpaceRef);
    return colorRef;
}

@end
