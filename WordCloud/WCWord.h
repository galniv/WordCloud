//
//  WCWord.h
//  WordCloud
//
//  Created by Gal Niv on 7/12/12.
//  Copyright (c) 2012. All rights reserved.
//

@interface WCWord : NSObject

@property (nonatomic, retain) NSString *text;
@property (nonatomic) int count;
@property (nonatomic) CGRect bounds;
@property (nonatomic) CGColorRef color;
@property UIFont *font;

- (id) initWithWord:(NSString *)word count:(int)count;

- (void) increaseCount;

@end
