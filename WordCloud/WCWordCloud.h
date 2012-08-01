//
//  WCWordCloud.h
//  WordCloud
//
//  Created by Gal Niv on 7/15/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "WCWord.h"
#import "WCWordCloudView.h"

@protocol WCWordCloudDelegate;

@interface WCWordCloud : UIViewController <WCWordCloudViewDelegate>

@property (nonatomic, retain) id<WCWordCloudDelegate> delegate;

// if specified, display only the most frequent words. default is unlimited
@property (nonatomic) int maxNumberOfWords;

// ignore all words shorter than this. defaults to 3
@property (nonatomic) int minimumWordLength;

@property (nonatomic, retain) UIFont *font;
// font size of the word with fewer occurances. defaults to 10
@property (nonatomic) int minFontSize;
// font size of the word with most occurances. defaults to 100
@property (nonatomic) int maxFontSize;

// both colors default to black
@property (nonatomic, retain) UIColor *lowCountColor;
@property (nonatomic, retain) UIColor *highCountColor;

// words will minimally have this many pixels between them. defaults to 2
@property (nonatomic) int wordBorderSize;

- (void)createWordCloud:(NSString *)wordString delimiter:(NSString *)delimiter;
- (void)createWordCloud:(NSArray *)words;

@end


@protocol WCWordCloudDelegate <NSObject>

@optional

- (void)wordCloud:(WCWordCloud *)wc didTapWord:(NSString *)word atPoint:(CGPoint)point;

@end