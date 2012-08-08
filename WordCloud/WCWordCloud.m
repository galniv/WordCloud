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
    NSMutableArray *sortedWords;
    double scalingFactor;
    double xShift;
    double yShift;
    
    NSMutableDictionary *wordCounts;
    CGFloat* lowCountColorComponents;
    CGFloat* highCountColorComponents;
    
    int highestWordCount;
    BOOL highestWordCountChanged;
    BOOL wordsNeedSorting;
    
    NSCharacterSet *nonLetterCharacterSet;
}

- (CGColorRef)CGColorRefFromUIColor:(UIColor*)newColor;
- (void)countWord:(NSString *)word;

@end

@implementation WCWordCloud

@synthesize maxNumberOfWords, minFontSize, maxFontSize, font, minimumWordLength, wordBorderSize, wordCloudSize;
@synthesize lowCountColor = _lowCountColor;
@synthesize highCountColor = _highCountColor;

- (id)init
{
    if (self = [super init]) {
        // defaults
        maxNumberOfWords = 0;
        minimumWordLength = 3;
        
        minFontSize = 10;
        maxFontSize = 100;
        font = [UIFont systemFontOfSize:minFontSize];
        
        self.lowCountColor = [UIColor blackColor];
        self.highCountColor = [UIColor blackColor];
        
        scalingFactor = 1;
        xShift = 0;
        yShift = 0;
        
        wordBorderSize = 2;
        highestWordCount = 0;
        
        wordsNeedSorting = FALSE;
        
        wordCounts = [[NSMutableDictionary alloc] init];
        
        nonLetterCharacterSet = [[NSCharacterSet letterCharacterSet] invertedSet];
    }
    return self;
}

- (void)dealloc
{
    font = nil;
    _lowCountColor = nil;
    _highCountColor = nil;
}

- (void)resetCloud
{
    highestWordCount = 0;
    
    wordsNeedSorting = FALSE;
    highestWordCountChanged = FALSE;
    
    [wordCounts removeAllObjects];
    [sortedWords removeAllObjects];
}

- (void)addWords:(NSString *)wordString delimiter:(NSString *)delimiter
{
    [self addWords:[wordString componentsSeparatedByString:delimiter]];
}

- (void)addWords:(NSArray *)words
{
    if (!words || words.count == 0) return;
    
    // count the number of occurences of each word
    for (NSString __strong *word in words)
    {
        // trim non-letter characters and convert to lower case
        word = [[word stringByTrimmingCharactersInSet:nonLetterCharacterSet] lowercaseString];
        
        // ignore all words shorter than the minimum word length
        if (word.length > minimumWordLength) {
            [self countWord:word];
        }
    }
    
    wordsNeedSorting = TRUE;
    [self generateCloud];
}

- (void)addWord:(NSString *)word
{
    [self countWord:[[word stringByTrimmingCharactersInSet:nonLetterCharacterSet] lowercaseString]];
    wordsNeedSorting = TRUE;
    [self generateCloud];
}

// private
- (void)countWord:(NSString *)word
{
    if (!word) return;
    
    if ([wordCounts objectForKey:word] == nil) {
        [wordCounts setValue:[[WCWord alloc] initWithWord:word count:1] forKey:word];
        
        if (highestWordCount == 0) {
            highestWordCount = 1;
            highestWordCountChanged = TRUE;
        }
    }
    else {
        WCWord *wcword = [wordCounts valueForKey:word];
        [wcword increaseCount];
        
        if (highestWordCount < wcword.count) {
            highestWordCount = wcword.count;
            highestWordCountChanged = TRUE;
        }
    }
}

// sorts words if needed, and lays them out
- (void)generateCloud
{
    if (wordCounts.count == 0) return;
    
    if (wordsNeedSorting) {
        // sort by number of occurences
        sortedWords = [NSMutableArray arrayWithArray:[[wordCounts allValues] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"count" ascending:FALSE]]]];
        
        wordsNeedSorting = FALSE;
    }
    
    // normalize font sizes based on the word with the highest number of occurances
    float fontSizePerOccurance = (maxFontSize - minFontSize) / highestWordCount;

    // prepare colors for interpolation
    float rColorPerOccurance = (highCountColorComponents[0] - lowCountColorComponents[0]) / highestWordCount;
    float gColorPerOccurance = (highCountColorComponents[1] - lowCountColorComponents[1]) / highestWordCount;
    float bColorPerOccurance = (highCountColorComponents[2] - lowCountColorComponents[2]) / highestWordCount;
    float aColorPerOccurance = (highCountColorComponents[3] - lowCountColorComponents[3]) / highestWordCount;

    WCWord *word;
    CGSize wordSize;

    double step = 2;
    double aspectRatio = wordCloudSize.width / wordCloudSize.height;
    double angle, radius, angleStep;
    int xPos, yPos, horizCenter, vertCenter;

    // statistics for later calculation of scaling factor
    int minX = INT_MAX;
    int maxX = INT_MIN;
    int minY = INT_MAX;
    int maxY = INT_MIN;

    int alreadyPlacedWordIdx;
    BOOL intersects = FALSE;

    int wordLimit = (maxNumberOfWords > 0 ? maxNumberOfWords : sortedWords.count);

    for (int i = 0; i < wordLimit; i++) {
        angle = 10 * random();
        radius = 0;
        angleStep = (i % 2 == 0 ? 1 : -1) * step;
        
        word = [sortedWords objectAtIndex:i];
        
        // only recalculate the word's size if its count has changed, or if the highest count has increased
        // (thus increasing the size per occurance)
        if (word.countChaged || highestWordCountChanged) {
            word.font = [font fontWithSize:minFontSize + (fontSizePerOccurance * word.count)];
            wordSize = [word.text sizeWithFont:word.font];
            wordSize.height += wordBorderSize * 2;
            wordSize.width += wordBorderSize * 2;
            
            word.color = [UIColor colorWithRed:lowCountColorComponents[0] + (rColorPerOccurance * word.count)
                                         green:lowCountColorComponents[1] + (gColorPerOccurance * word.count)
                                          blue:lowCountColorComponents[2] + (bColorPerOccurance * word.count)
                                         alpha:lowCountColorComponents[3] + (aColorPerOccurance * word.count)].CGColor;
            
            word.countChaged = FALSE;
        }
        
        word.bounds = CGRectMake(arc4random_uniform(10) + (wordCloudSize.width / 2), arc4random_uniform(10) + (wordCloudSize.height / 2), wordSize.width, wordSize.height);
        
        horizCenter = (wordCloudSize.width / 2) - (wordSize.width / 2);
        vertCenter = (wordCloudSize.height / 2) - (wordSize.height / 2);
        
        // move word until there are no collisions with previously placed words
        // adapted from https://github.com/lucaong/jQCloud
        do {
            for (alreadyPlacedWordIdx = 0; alreadyPlacedWordIdx <= i - 1; alreadyPlacedWordIdx++) {
                intersects = CGRectIntersectsRect(word.bounds, ((WCWord *)[sortedWords objectAtIndex:(alreadyPlacedWordIdx)]).bounds);
                
                // if the current word intersects with word that has already been placed, move the current word, and
                // recheck against all already-placed words
                if (intersects) {
                    radius += step;
                    angle += angleStep;
                    
                    xPos = horizCenter + (radius * cos(angle)) * aspectRatio;
                    yPos = vertCenter + radius * sin(angle);
                    
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
    
    // finished processing words; start monitoring the highest word count again.
    highestWordCountChanged = FALSE;
    
    scalingFactor = 1;

    // scale down if necessary
    if (maxX - minX > wordCloudSize.width) {
        scalingFactor = wordCloudSize.width / (double)(maxX - minX);
        
        // if we are here, then words are larger than the view, and either minX is negative or maxX is larger than the width.
        // calculate the amount by which to shift all words so that they fit in the view.
        if (minX < 0) xShift = minX * scalingFactor * -1;
        else xShift = (wordCloudSize.width - maxX) * scalingFactor;
    }
    
    if (maxY - minY > wordCloudSize.height) {
        double newScalingFactor = wordCloudSize.height / (double)(maxY - minY);
        
        // if we've already scaled down in the X dimension, only apply the new scale if it is smaller
        if (scalingFactor < 1 && newScalingFactor < scalingFactor) {
            scalingFactor = newScalingFactor;
        }
        
        // if we are here, then words are larger than the view, and either minX is negative or maxX is larger than the width.
        // calculate the amount by which to shift all words so that they fit in the view.
        if (minY < 0) yShift = minY * scalingFactor * -1;
        else yShift = (wordCloudSize.height - maxY) * scalingFactor;
    }
    
    if ([self.delegate respondsToSelector:@selector(wordCloudDidGenerateCloud:sortedWordArray:scalingFactor:xShift:yShift:)]) {
        [self.delegate wordCloudDidGenerateCloud:self sortedWordArray:sortedWords scalingFactor:scalingFactor xShift:xShift yShift:yShift];
    }
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

// accessors
- (void)setLowCountColor:(UIColor *)color
{
    _lowCountColor = color;
    
    lowCountColorComponents = (CGFloat *)CGColorGetComponents([self CGColorRefFromUIColor:_lowCountColor]);
    lowCountColorComponents[3] = CGColorGetAlpha(_lowCountColor.CGColor);
}

- (void)setHighCountColor:(UIColor *)color
{
    _highCountColor = color;
    
    highCountColorComponents = (CGFloat *)CGColorGetComponents([self CGColorRefFromUIColor:_highCountColor]);
    highCountColorComponents[3] = CGColorGetAlpha(_highCountColor.CGColor);
}

@end
