//
//  EIWaterfallCollectionViewCell.m
//  WaterfallCollectionView
//
//  Created by Miroslaw Stanek on 12.07.2013.
//  Copyright (c) 2013 Event Info Ltd. All rights reserved.
//

#import "EIWaterfallCollectionViewCell.h"

@interface EIWaterfallCollectionViewCell()

@property (nonatomic, strong, readwrite) UILabel *titleLabel;

@end

@implementation EIWaterfallCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
        self.titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        self.titleLabel.textColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
        self.titleLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
        self.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        
        [self addSubview:self.titleLabel];
    }
    return self;
}

@end
