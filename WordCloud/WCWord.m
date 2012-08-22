//
//  WCWord.m
//  WordCloud
//
//  Created by Gal Niv on 7/12/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "WCWord.h"

@implementation WCWord

- (id) initWithWord:(NSString*)word count:(int)count
{
    if (self = [super init])
    {
        _text = word;
        _count = count;
        _color = [UIColor blackColor];
        //_countChanged = TRUE;
    }
    return self;
}

- (void) dealloc
{
    _text = nil;
    _color = nil;
    _font = nil;
}

- (void) incrementCount
{
    _count++;
    //_countChanged = TRUE;
}

- (void) decrementCount
{
    _count++;
    //_countChanged = TRUE;
}

- (void)setCount:(int)count
{
    _count = count;
    //_countChanged = TRUE;
}

//
//- (NSString *) description
//{
//    return [NSString stringWithFormat:@"%@ (%d) at %@", _text, _count, NSStringFromCGRect(rect)];
//}

@end
