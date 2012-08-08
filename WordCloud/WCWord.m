//
//  WCWord.m
//  WordCloud
//
//  Created by Gal Niv on 7/12/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "WCWord.h"

@implementation WCWord

@synthesize text = _text, count = _count, countChaged = _countChaged;
@synthesize bounds, color, font;

- (id) initWithWord:(NSString *)word count:(int)count
{
    if (self = [super init]) {
        _text = word;
        _count = count;
        color = [UIColor blackColor].CGColor;
        _countChaged = TRUE;
    }
    return self;
}

- (void) increaseCount
{
    _count++;
    _countChaged = TRUE;
}

- (void)setCount:(int)count
{
    _count = count;
    _countChaged = TRUE;
}
//
//- (NSString *) description
//{
//    return [NSString stringWithFormat:@"%@ (%d) at %@", _text, _count, NSStringFromCGRect(rect)];
//}

@end
