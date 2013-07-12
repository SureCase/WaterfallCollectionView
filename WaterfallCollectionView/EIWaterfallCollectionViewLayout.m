//
//  EIWaterfallCollectionViewLayout.m
//  WaterfallCollectionView
//
//  Created by Miroslaw Stanek on 12.07.2013.
//  Copyright (c) 2013 Event Info Ltd. All rights reserved.
//

#import "EIWaterfallCollectionViewLayout.h"

static NSString * const EIWaterfallLayoutCellKind = @"WaterfallCell";
NSString * const EIWaterfallTitleKind = @"WaterfalHeader";

@interface EIWaterfallCollectionViewLayout()

@property (nonatomic, strong) NSDictionary *layoutInfo;
@property (nonatomic, strong) NSArray *sectionsHeights;

@end

@implementation EIWaterfallCollectionViewLayout

#pragma mark - Lifecycle

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)setTitleHeight:(CGFloat)titleHeight {
    if (_titleHeight == titleHeight) return;
    
    _titleHeight = titleHeight;
    
    [self invalidateLayout];
}

- (void)setup {
    self.itemInsets = UIEdgeInsetsMake(22.0f, 22.0f, 13.0f, 22.0f);
    self.itemSize = CGSizeMake(125.0f, 125.0f);
    self.numberOfColumns = 2;
    self.titleHeight = 26.0f;
    
    self.itemInnerMargin = 0;
}

- (void)prepareLayout {
    if(self.numberOfColumns > 1) {
        self.itemInnerMargin =
            (self.collectionView.bounds.size.width -
             self.itemInsets.left -
             self.itemInsets.right -
             self.numberOfColumns * self.itemSize.width)
            /
            (self.numberOfColumns - 1);
    }
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *titleLayoutInfo = [NSMutableDictionary dictionary];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    /*--- SECTIONS ---*/
    NSMutableArray *newSectionsHeights = [NSMutableArray array];
    for (NSInteger section = 0; section < sectionCount; section++) {
        [newSectionsHeights addObject:[self calculateHeightForSection:[NSNumber numberWithInt:section]]];
    }
    self.sectionsHeights = [NSArray arrayWithArray:newSectionsHeights];
    
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        for (NSInteger item = 0; item < itemCount; item++) {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            itemAttributes.frame = [self frameForWaterfallCellIndexPath:indexPath];
            
            cellLayoutInfo[indexPath] = itemAttributes;
            
            if (indexPath.item == 0) {
                UICollectionViewLayoutAttributes *titleAttributes = [UICollectionViewLayoutAttributes
                                                                     layoutAttributesForSupplementaryViewOfKind:EIWaterfallTitleKind
                                                                     withIndexPath:indexPath];
                titleAttributes.frame = [self frameForAlbumTitleAtIndexPath:indexPath];
                titleLayoutInfo[indexPath] = titleAttributes;
            }
        }
    }
    
    newLayoutInfo[EIWaterfallLayoutCellKind] = cellLayoutInfo;
    newLayoutInfo[EIWaterfallTitleKind] = titleLayoutInfo;
    
    self.layoutInfo = newLayoutInfo;
    
}

- (void) calculateSectionsHeights {
    
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];
    
    [self.layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSString *elementIdentifier,
                                                         NSDictionary *elementsInfo,
                                                         BOOL *stop) {
    [elementsInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath,
                                                          UICollectionViewLayoutAttributes *attributes,
                                                          BOOL *innerStop) {
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [allAttributes addObject:attributes];
            }
        }];
    }];
    
    return allAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.layoutInfo[EIWaterfallLayoutCellKind][indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind
                                                                     atIndexPath:(NSIndexPath *)indexPath {
    return self.layoutInfo[EIWaterfallTitleKind][indexPath];
}

- (CGSize)collectionViewContentSize {
    CGFloat height = self.itemInsets.top;
    for (NSNumber *h in self.sectionsHeights) {
        height += [h integerValue];
    }
    height += self.itemInsets.bottom;
    
    return CGSizeMake(self.collectionView.bounds.size.width, height);
}

#pragma mark - Private

- (CGRect)frameForWaterfallCellIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemMargin =
    (self.collectionView.bounds.size.width -
     self.itemInsets.left -
     self.itemInsets.right -
     self.numberOfColumns * self.itemSize.width)
    /
    (self.numberOfColumns - 1);
    CGFloat width = self.itemSize.width;
    CGFloat height = [self.delegate collectionView:self.collectionView
                                            layout:self
                          heightForItemAtIndexPath:indexPath];
    
    CGFloat topInset = 0;
    for (NSInteger section = 0; section < indexPath.section; section++) {
        topInset += [[self.sectionsHeights objectAtIndex:section] integerValue];
    }

    NSInteger columnsHeights[self.numberOfColumns];
    for (NSInteger column = 0; column < self.numberOfColumns; column++) {
        columnsHeights[column] = self.titleHeight;
    }
    
    for (NSInteger item = 0; item < indexPath.item; item++) {
        NSIndexPath *ip = [NSIndexPath indexPathForItem:item inSection:indexPath.section];
        NSInteger currentColumn = 0;
        for(NSInteger column = 0; column < self.numberOfColumns; column++) {
            if(columnsHeights[currentColumn] > columnsHeights[column]) {
                currentColumn = column;
            }
        }
                
        columnsHeights[currentColumn] += [self.delegate collectionView:self.collectionView
                                                layout:self
                              heightForItemAtIndexPath:ip];
        columnsHeights[currentColumn] += self.itemInnerMargin;
    }
    
    NSInteger columnForCurrentItem = 0;
    for (NSInteger column = 0; column < self.numberOfColumns; column++) {
        if(columnsHeights[columnForCurrentItem] > columnsHeights[column]) {
            columnForCurrentItem = column;
        }
    }
    
    CGFloat originX = self.itemInsets.left + (columnForCurrentItem * (self.itemSize.width) + columnForCurrentItem * itemMargin);
    CGFloat originY = self.itemInsets.top + columnsHeights[columnForCurrentItem] + topInset;
    
    return CGRectMake(originX, originY, width, height);
}

- (CGRect)frameForAlbumTitleAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = self.collectionView.bounds.size.width -
        self.itemInsets.left -
        self.itemInsets.right;
    CGFloat height = self.titleHeight;
    
    CGFloat originY = 0;
    for (NSInteger i = 0; i < indexPath.section; i++) {
        originY += [[self.sectionsHeights objectAtIndex:i] integerValue];
    }
        
    CGFloat originX = self.itemInsets.left;

    return CGRectMake(originX, originY, width, height);
}

- (NSNumber*) calculateHeightForSection: (NSNumber*)sectionNumber {
    int sectionColumns[self.numberOfColumns];
    for (int column = 0; column < self.numberOfColumns; column++) {
        sectionColumns[column] = 0;
    }
    
    int section = [sectionNumber integerValue];
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
    NSIndexPath *indexPath;
    for (NSInteger item = 0; item < itemCount; item++) {
        indexPath = [NSIndexPath indexPathForItem:item inSection:section];
        
        int currentColumn = 0;
        for (int column = 0; column < self.numberOfColumns; column++) {
            if(sectionColumns[currentColumn] > sectionColumns[column]) {
                currentColumn = column;
            }
        }
        
        sectionColumns[currentColumn] += [self.delegate collectionView:self.collectionView
                                                                layout:self
                                              heightForItemAtIndexPath:indexPath];
        sectionColumns[currentColumn] += self.itemInnerMargin;
    }
    
    int biggestColumn = 0;
    for (int column = 0; column < self.numberOfColumns; column++) {
        if(sectionColumns[biggestColumn] < sectionColumns[column]) {
            biggestColumn = column;
        }
    }
    
    return
    [NSNumber numberWithInt:
        self.titleHeight +
        sectionColumns[biggestColumn]];
}

@end
