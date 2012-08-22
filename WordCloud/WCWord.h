//
//  WCWord.h
//  WordCloud
//
//  Created by Gal Niv on 7/12/12.
//  Copyright (c) 2012. All rights reserved.
//

@interface WCWord : NSObject

@property (nonatomic, retain, readonly) NSString* text;
@property (nonatomic, readonly) int count;
@property (nonatomic) CGRect bounds;
@property (nonatomic, retain) UIColor* color;
@property (nonatomic, retain) UIFont* font;
//@property (nonatomic) BOOL countChanged;

- (id) initWithWord:(NSString*)word count:(int)count;

- (void) incrementCount;
- (void) decrementCount;

@end
