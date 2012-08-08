//
//  WCWordCloudViewController.m
//  elements
//
//  Created by Gal Niv on 8/7/12.
//  Copyright (c) 2012 exploros. All rights reserved.
//

#import "WCWordCloudViewController.h"

@interface WCWordCloudViewController ()
{
    WCWordCloudView *wcView;
    WCWordCloud *wc;
}

@end

@implementation WCWordCloudViewController

@synthesize wordCloud;

- (id)init
{
    return [self initWithNibName:nil bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        wc = [[WCWordCloud alloc] init];
        wc.delegate = self;
        
        wcView = [[WCWordCloudView alloc] init];
        wcView.delegate = self;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    [self.view addSubview:wcView];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    wcView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [wcView setNeedsDisplay];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

// WCWordCloudDelegate
- (void)wordCloudDidGenerateCloud:(WCWordCloud *)wc sortedWordArray:(NSArray *)words scalingFactor:(double)scalingFactor xShift:(double)xShift yShift:(double)yShift
{
    wcView.words = words;
    wcView.scalingFactor = scalingFactor;
    wcView.xShift = xShift;
    wcView.yShift = yShift;
}

// WCWordCloudViewDelegate
- (void)wordCloudView:(WCWordCloudView *)wcView didTapWord:(WCWord *)word atPoint:(CGPoint)point
{
    if ([self.delegate respondsToSelector:@selector(wordCloud:didTapWord:atPoint:)]) {
        [self.delegate wordCloud:wc didTapWord:word.text atPoint:point];
    }
}

// accessors
- (WCWordCloud *)wordCloud
{
    return wc;
}

@end
