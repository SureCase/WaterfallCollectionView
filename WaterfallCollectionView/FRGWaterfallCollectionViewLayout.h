//
//  FRGWaterfallCollectionViewLayout.h
//  WaterfallCollectionView
//
//  Created by Miroslaw Stanek on 12.07.2013.
//  Copyright (c) 2013 Event Info Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FRGWaterfallCollectionViewLayout;

@protocol FRGWaterfallCollectionViewDelegate <UICollectionViewDelegate>

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(FRGWaterfallCollectionViewLayout *)collectionViewLayout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

- (CGFloat) collectionView:(UICollectionView *)collectionView
                    layout:(FRGWaterfallCollectionViewLayout *)collectionViewLayout
heightForHeaderAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface FRGWaterfallCollectionViewLayout : UICollectionViewLayout

@property (nonatomic, weak) IBOutlet id<FRGWaterfallCollectionViewDelegate> delegate;
@property (nonatomic) CGFloat itemWidth;

@property (nonatomic) CGFloat topInset;
@property (nonatomic) CGFloat bottomInset;
@property (nonatomic) BOOL stickyHeader;

@end
