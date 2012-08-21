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
    /*
    double scalingFactor;
    double xShift;
    double yShift;
    */
    
    NSMutableDictionary* wordCounts;
    CGFloat* lowCountColorComponents;
    CGFloat* highCountColorComponents;
    
    int highestWordCount;
    BOOL highestWordCountChanged;
    BOOL wordsNeedSorting;
    
    NSCharacterSet* nonLetterCharacterSet;
}

- (CGColorRef)CGColorRefFromUIColor:(UIColor*)newColor;
- (void)countWord:(NSString *)word;

@end

@implementation WCWordCloud

//@synthesize delegate = _delegate;
//@synthesize maxNumberOfWords, minFontSize, maxFontSize, font, minimumWordLength, wordBorderSize, wordCloudSize;
//@synthesize lowCountColor = _lowCountColor;
//@synthesize highCountColor = _highCountColor;

- (id)init
{
    if (self = [super init])
    {
        // defaults
        _maxNumberOfWords = 0;
        _minimumWordLength = 3;
        
        _minFontSize = 10;
        _maxFontSize = 100;
        _font = [UIFont systemFontOfSize:self.minFontSize];
        
        self.lowCountColor = [UIColor blackColor];
        self.highCountColor = [UIColor blackColor];
        
        _wordCloudSize = CGSizeZero;
        //scalingFactor = 1;
        //xShift = 0;
        //yShift = 0;
        
        _wordBorderSize = 2;
        highestWordCount = 0;
        
        wordsNeedSorting = FALSE;
        
        wordCounts = [[NSMutableDictionary alloc] init];
        
        nonLetterCharacterSet = [[NSCharacterSet letterCharacterSet] invertedSet];
    }
    return self;
}

- (void) dealloc
{
    _delegate = nil;
    
    _font = nil;
    
    sortedWords = nil;
    wordCounts = nil;
    
    lowCountColorComponents = nil;
    highCountColorComponents = nil;
    
    nonLetterCharacterSet = nil;
    
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

- (void) addWords:(NSString*) wordString delimiter:(NSString*)delimiter
{
    if (!wordString.length) return;
    [self addWords:[wordString componentsSeparatedByString:delimiter]];
}

- (void) addWords:(NSArray*)words
{
    if (!words.count) return;
    
    // count the number of occurences of each word
    for (NSString* word in words)
    {
        // trim non-letter characters and convert to lower case
        NSString* cleanWord = [[word stringByTrimmingCharactersInSet:nonLetterCharacterSet] lowercaseString];
        // ignore all words shorter than the minimum word length
        if (cleanWord.length > self.minimumWordLength) [self countWord:cleanWord];
    }
    
    wordsNeedSorting = TRUE;
    [self generateCloud];
}

- (void) addWord:(NSString*)word
{
    if (!word.length) return;
    [self countWord:[[word stringByTrimmingCharactersInSet:nonLetterCharacterSet] lowercaseString]];
    wordsNeedSorting = TRUE;
    [self generateCloud];
}

// private
- (void) countWord:(NSString*)word
{
    if (!word.length) return;
    
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
- (void) generateCloud
{
    double scalingFactor;
    double xShift;
    double yShift;
    
    if (!wordCounts.count) return;
    if (true == CGSizeEqualToSize(self.wordCloudSize, CGSizeZero)) return;
    
    if (wordsNeedSorting) {
        wordsNeedSorting = FALSE;
        // sort by number of occurences
        sortedWords = [NSMutableArray arrayWithArray:[[wordCounts allValues] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"count" ascending:FALSE]]]];
    }
    
    // normalize font sizes based on the word with the highest number of occurances
    float fontSizePerOccurance = (self.maxFontSize - self.minFontSize) / highestWordCount;

    // prepare colors for interpolation
    float rColorPerOccurance = (highCountColorComponents[0] - lowCountColorComponents[0]) / highestWordCount;
    float gColorPerOccurance = (highCountColorComponents[1] - lowCountColorComponents[1]) / highestWordCount;
    float bColorPerOccurance = (highCountColorComponents[2] - lowCountColorComponents[2]) / highestWordCount;
    float aColorPerOccurance = (highCountColorComponents[3] - lowCountColorComponents[3]) / highestWordCount;

    //WCWord *word;
    //CGSize wordSize;

    double step = 2;
    double aspectRatio = self.wordCloudSize.width / self.wordCloudSize.height;
    //double angle, radius, angleStep;


    // statistics for later calculation of scaling factor
    int minX = INT_MAX;
    int maxX = INT_MIN;
    int minY = INT_MAX;
    int maxY = INT_MIN;
    int wordLimit = (self.maxNumberOfWords > 0 ? self.maxNumberOfWords : sortedWords.count);

    for (int i = 0; i < wordLimit; i++)
    {
        //int xPos, yPos, horizCenter, vertCenter;
        //int alreadyPlacedWordIdx;
        BOOL intersects = FALSE;
        
        double angle = 10 * random();
        double radius = 0;
        double angleStep = (i % 2 == 0 ? 1 : -1) * step;
        
        WCWord* word = [sortedWords objectAtIndex:i];
        
        // only recalculate the word's size if its count has changed, or if the highest count has increased
        // (thus increasing the size per occurance)
        if (word.countChanged || highestWordCountChanged) {
            word.font = [self.font fontWithSize:self.minFontSize + (fontSizePerOccurance * word.count)];
                        
            word.color = [UIColor colorWithRed:lowCountColorComponents[0] + (rColorPerOccurance * word.count)
                                         green:lowCountColorComponents[1] + (gColorPerOccurance * word.count)
                                          blue:lowCountColorComponents[2] + (bColorPerOccurance * word.count)
                                         alpha:lowCountColorComponents[3] + (aColorPerOccurance * word.count)];
            
            word.countChanged = FALSE;
        }
        
        CGSize wordSize = [word.text sizeWithFont:word.font];
        wordSize.height += self.wordBorderSize * 2;
        wordSize.width += self.wordBorderSize * 2;
        
        word.bounds = CGRectMake(arc4random_uniform(10) + (self.wordCloudSize.width / 2), arc4random_uniform(10) + (self.wordCloudSize.height / 2), wordSize.width, wordSize.height);
        
        int horizCenter = (self.wordCloudSize.width / 2) - (wordSize.width / 2);
        int vertCenter = (self.wordCloudSize.height / 2) - (wordSize.height / 2);
        
        // move word until there are no collisions with previously placed words
        // adapted from https://github.com/lucaong/jQCloud
        do {
            for (int alreadyPlacedWordIdx = 0; alreadyPlacedWordIdx <= i - 1; alreadyPlacedWordIdx++) {
                intersects = CGRectIntersectsRect(word.bounds, ((WCWord *)[sortedWords objectAtIndex:(alreadyPlacedWordIdx)]).bounds);
                
                // if the current word intersects with word that has already been placed, move the current word, and
                // recheck against all already-placed words
                if (intersects) {
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
    
    // finished processing words; start monitoring the highest word count again.
    highestWordCountChanged = FALSE;
    
    scalingFactor = 1;

    // scale down if necessary
    if (maxX - minX > self.wordCloudSize.width) {
        scalingFactor = self.wordCloudSize.width / (double)(maxX - minX);
        
        // if we are here, then words are larger than the view, and either minX is negative or maxX is larger than the width.
        // calculate the amount by which to shift all words so that they fit in the view.
        if (minX < 0) xShift = minX * scalingFactor * -1;
        else xShift = (self.wordCloudSize.width - maxX) * scalingFactor;
    }
    
    if (maxY - minY > self.wordCloudSize.height) {
        double newScalingFactor = self.wordCloudSize.height / (double)(maxY - minY);
        
        // if we've already scaled down in the X dimension, only apply the new scale if it is smaller
        if (scalingFactor < 1 && newScalingFactor < scalingFactor) {
            scalingFactor = newScalingFactor;
        }
        
        // if we are here, then words are larger than the view, and either minX is negative or maxX is larger than the width.
        // calculate the amount by which to shift all words so that they fit in the view.
        if (minY < 0) yShift = minY * scalingFactor * -1;
        else yShift = (self.wordCloudSize.height - maxY) * scalingFactor;
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
- (void) setLowCountColor:(UIColor*)color
{
    _lowCountColor = color;
    
    lowCountColorComponents = (CGFloat*)CGColorGetComponents([self CGColorRefFromUIColor:color]);
    lowCountColorComponents[3] = CGColorGetAlpha(color.CGColor);
}

- (void) setHighCountColor:(UIColor*)color
{
    _highCountColor = color;
    
    highCountColorComponents = (CGFloat*)CGColorGetComponents([self CGColorRefFromUIColor:color]);
    highCountColorComponents[3] = CGColorGetAlpha(color.CGColor);
}

@end
