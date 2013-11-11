//
//  EIViewController.m
//  WaterfallCollectionView
//
//  Created by Miroslaw Stanek on 12.07.2013.
//  Copyright (c) 2013 Event Info Ltd. All rights reserved.
//

#import "EIViewController.h"
#import "FRGWaterfallCollectionViewCell.h"
#import "FRGWaterfallCollectionViewLayout.h"
#import "FRGWaterfallHeaderReusableView.h"

static NSString* const WaterfallCellIdentifier = @"WaterfallCell";
static NSString* const WaterfallHeaderIdentifier = @"WaterfallHeader";

@interface EIViewController () <FRGWaterfallCollectionViewDelegate, UICollectionViewDelegate>

@property (nonatomic, strong) NSMutableArray *cellHeights;

@end

@implementation EIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cv.delegate = self;
    
    FRGWaterfallCollectionViewLayout *cvLayout = [[FRGWaterfallCollectionViewLayout alloc] init];
    cvLayout.delegate = self;
    cvLayout.itemWidth = 140.0f;
    cvLayout.topInset = 10.0f;
    cvLayout.bottomInset = 10.0f;
    cvLayout.stickyHeader = YES;
    
    [self.cv setCollectionViewLayout:cvLayout];
    [self.cv reloadData];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [[self.cv collectionViewLayout] invalidateLayout];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 30;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return 30;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FRGWaterfallCollectionViewCell *waterfallCell = [collectionView dequeueReusableCellWithReuseIdentifier:WaterfallCellIdentifier
                                                                                             forIndexPath:indexPath];
    waterfallCell.lblTitle.text = [NSString stringWithFormat: @"Item %d", indexPath.item];
    return waterfallCell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(FRGWaterfallCollectionViewLayout *)collectionViewLayout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cellHeights[indexPath.section + 1 * indexPath.item] floatValue];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(FRGWaterfallCollectionViewLayout *)collectionViewLayout
heightForHeaderAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section + 1) * 26.0f;
}

- (NSMutableArray *)cellHeights {
    if (!_cellHeights) {
        _cellHeights = [NSMutableArray arrayWithCapacity:900];
        for (NSInteger i = 0; i < 900; i++) {
            _cellHeights[i] = @(arc4random()%100*2+100);
        }
    }
    return _cellHeights;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath; {
    FRGWaterfallHeaderReusableView *titleView =
    [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                       withReuseIdentifier:WaterfallHeaderIdentifier
                                              forIndexPath:indexPath];
    titleView.lblTitle.text = [NSString stringWithFormat: @"Section %d", indexPath.section];
    return titleView;
}

@end
