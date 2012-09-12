//
//  WCWordCloud.h
//  WordCloud
//
//  Created by Gal Niv on 7/15/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "WCWord.h"

@protocol WCWordCloudDelegate;

@interface WCWordCloud : NSObject

@property (nonatomic, weak) id <WCWordCloudDelegate> delegate;

// if specified, display only the most frequent words. default is unlimited
@property (nonatomic) int maxNumberOfWords;

// ignore all words shorter than this. defaults to 3
@property (nonatomic) int minimumWordLength;

@property (nonatomic, retain) UIFont* font;
// font size of the word with fewer occurances. defaults to 10
@property (nonatomic) int minFontSize;
// font size of the word with most occurances. defaults to 100
@property (nonatomic) int maxFontSize;

// both colors default to black
@property (nonatomic, retain) UIColor* lowCountColor;
@property (nonatomic, retain) UIColor* highCountColor;

// words will minimally have this many pixels between them. defaults to 2
@property (nonatomic) int wordBorderSize;

// the size of the word cloud
@property (nonatomic) CGSize cloudSize;

- (void)rebuild:(NSArray*)words;

// add words to the cloud
- (void)addWords:(NSString*)wordString delimiter:(NSString *)delimiter;
- (void)addWords:(NSArray*)words;
- (void)addWord:(NSString*)word;

// remove words from cloud
- (void)removeWord:(NSString*)word;
- (void)removeWords:(NSArray*)words;
- (void)removeAllWords;

// regenerate the cloud using current words and settings
//- (void)generateCloud;

// reset the cloud, removing all words
//- (void)resetCloud;

@end


@protocol WCWordCloudDelegate <NSObject>

@optional

- (void)wordCloudDidGenerateCloud:(WCWordCloud *)wc sortedWordArray:(NSArray *)words scalingFactor:(double)scalingFactor xShift:(double)xShift yShift:(double)yShift;

@end