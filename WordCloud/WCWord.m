//
//  WCWord.m
//  WordCloud
//
//  Created by Gal Niv on 7/12/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "WCWord.h"

@implementation WCWord

@synthesize text = _text, count = _count;
@synthesize bounds, color, font;

- (id) initWithWord:(NSString *)word count:(int)count
{
    if (self = [super init]) {
        _text = word;
        _count = count;
        color = [UIColor blackColor].CGColor;
    }
    return self;
}

- (void) increaseCount
{
    _count++;
}
//
//- (NSString *) description
//{
//    return [NSString stringWithFormat:@"%@ (%d) at %@", _text, _count, NSStringFromCGRect(rect)];
//}

@end
