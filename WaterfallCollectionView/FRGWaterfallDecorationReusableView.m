//
//  FRGWaterfallDecorationReusableView.m
//  WaterfallCollectionView
//
//  Created by Miroslaw Stanek on 14.07.2013.
//  Copyright (c) 2013 Event Info Ltd. All rights reserved.
//

#import "FRGWaterfallDecorationReusableView.h"

@implementation FRGWaterfallDecorationReusableView


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *image = [UIImage imageNamed:@"decorationImage"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = self.bounds;
        [self addSubview:imageView];
    }
    return self;
}

+ (CGSize)defaultSize {
    return [UIImage imageNamed:@"decorationImage"].size;
}

@end
