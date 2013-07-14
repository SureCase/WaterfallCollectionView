//
//  EIWaterfallCollectionViewLayout.m
//  WaterfallCollectionView
//
//  Created by Miroslaw Stanek on 12.07.2013.
//  Copyright (c) 2013 Event Info Ltd. All rights reserved.
//

#import "EIWaterfallCollectionViewLayout.h"
#import "EIWaterfallDecorationReusableView.h"

NSString* const EIWaterfallLayoutCellKind = @"WaterfallCell";
NSString* const EIWaterfallLayouDecorationKind = @"Decoration";

@interface EIWaterfallCollectionViewLayout()

@property (nonatomic) NSInteger columnsCount;
@property (nonatomic) CGFloat itemInnerMargin;
@property (nonatomic) NSDictionary *layoutInfo;
@property (nonatomic) NSArray *sectionsHeights;
@property (nonatomic) NSArray *itemsInSectionsHeights;

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

- (void)setHeaderHeight:(CGFloat)headerHeight {
    if (_headerHeight == headerHeight) return;
    _headerHeight = headerHeight;
    [self invalidateLayout];
}

- (void) setItemWidth:(CGFloat)itemWidth {
    if(_itemWidth == itemWidth) return;
    _itemWidth = itemWidth;
    [self invalidateLayout];
}

- (void)setup {
    [self registerClass:[EIWaterfallDecorationReusableView class] forDecorationViewOfKind:EIWaterfallLayouDecorationKind];
    self.itemInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    self.headerHeight = 26.0f;
    self.itemWidth = 135.0f;
    self.itemInnerMargin = 0;
}

- (void)prepareLayout {
    [self calculateMaxColumnsCount];
    [self calculateItemsInnerMargin];
    [self calculateItemsHeights];
    [self calculateSectionsHeights];
    [self calculateItemsAttributes];
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
    return self.layoutInfo[UICollectionElementKindSectionHeader][indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:
(NSString*)decorationViewKind atIndexPath:(NSIndexPath *)indexPath {
    return self.layoutInfo[EIWaterfallLayouDecorationKind][indexPath];
}

- (CGSize)collectionViewContentSize {
    CGFloat height = self.itemInsets.top;
    for (NSNumber *h in self.sectionsHeights) {
        height += [h integerValue];
    }
    height += self.itemInsets.bottom;
    
    return CGSizeMake(self.collectionView.bounds.size.width, height);
}

#pragma mark - Prepare layout calculation

- (void) calculateMaxColumnsCount {
    self.columnsCount = self.collectionView.bounds.size.width / self.itemWidth;
}

- (void) calculateItemsInnerMargin {
    if(self.columnsCount > 1) {
        self.itemInnerMargin =
        (self.collectionView.bounds.size.width -
         self.itemInsets.left - self.itemInsets.right -
         self.columnsCount * self.itemWidth)
        /
        (self.columnsCount - 1);
    }
}

- (void) calculateItemsHeights {
    NSMutableArray *itemsInSectionsHeights = [NSMutableArray arrayWithCapacity:self.collectionView.numberOfSections];
    NSIndexPath *itemIndex;
    for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++) {
        NSMutableArray *itemsHeights = [NSMutableArray arrayWithCapacity:[self.collectionView numberOfItemsInSection:section]];
        for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
            itemIndex = [NSIndexPath indexPathForItem:item inSection:section];
            CGFloat itemHeight = [self.delegate collectionView:self.collectionView
                                                        layout:self
                                      heightForItemAtIndexPath:itemIndex];
            [itemsHeights addObject:[NSNumber numberWithFloat:itemHeight]];
        }
        [itemsInSectionsHeights addObject:itemsHeights];
    }
    
    self.itemsInSectionsHeights = itemsInSectionsHeights;
}

- (void) calculateSectionsHeights {
    NSMutableArray *newSectionsHeights = [NSMutableArray array];
    NSInteger sectionCount = [self.collectionView numberOfSections];
    for (NSInteger section = 0; section < sectionCount; section++) {
        [newSectionsHeights addObject:[self calculateHeightForSection:section]];
    }
    self.sectionsHeights = [NSArray arrayWithArray:newSectionsHeights];
}

- (NSNumber*) calculateHeightForSection: (NSInteger)section {
    NSInteger sectionColumns[self.columnsCount];
    for (NSInteger column = 0; column < self.columnsCount; column++) {
        sectionColumns[column] = self.headerHeight + self.itemInnerMargin;
    }
    
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
    NSIndexPath *indexPath;
    for (NSInteger item = 0; item < itemCount; item++) {
        indexPath = [NSIndexPath indexPathForItem:item inSection:section];
        
        NSInteger currentColumn = 0;
        for (NSInteger column = 0; column < self.columnsCount; column++) {
            if(sectionColumns[currentColumn] > sectionColumns[column]) {
                currentColumn = column;
            }
        }
        
        sectionColumns[currentColumn] += [[[self.itemsInSectionsHeights objectAtIndex:section]
                                           objectAtIndex:indexPath.item] floatValue];
        sectionColumns[currentColumn] += self.itemInnerMargin;
    }
    
    int biggestColumn = 0;
    for (NSInteger column = 0; column < self.columnsCount; column++) {
        if(sectionColumns[biggestColumn] < sectionColumns[column]) {
            biggestColumn = column;
        }
    }
    
    return [NSNumber numberWithFloat: sectionColumns[biggestColumn]];
}

- (void) calculateItemsAttributes {
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *titleLayoutInfo = [NSMutableDictionary dictionary];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewLayoutAttributes *emblemAttributes =
    [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:EIWaterfallLayouDecorationKind
                                                                withIndexPath:indexPath];
    emblemAttributes.frame = [self frameForWaterfallDecoration];
    
    for (NSInteger section = 0; section < [self.collectionView numberOfSections]; section++) {
        for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            itemAttributes.frame = [self frameForWaterfallCellIndexPath:indexPath];
            cellLayoutInfo[indexPath] = itemAttributes;
            
            //Only one header in section, so we get only item at 0 position
            if (indexPath.item == 0) {
                UICollectionViewLayoutAttributes *titleAttributes = [UICollectionViewLayoutAttributes
                                                                     layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                     withIndexPath:indexPath];
                titleAttributes.frame = [self frameForWaterfallHeaderAtIndexPath:indexPath];
                titleLayoutInfo[indexPath] = titleAttributes;
            }
        }
    }
    
    newLayoutInfo[EIWaterfallLayoutCellKind] = cellLayoutInfo;
    newLayoutInfo[UICollectionElementKindSectionHeader] = titleLayoutInfo;
    newLayoutInfo[EIWaterfallLayouDecorationKind] = @{indexPath: emblemAttributes};
    
    self.layoutInfo = newLayoutInfo;
    
}

#pragma mark - Items frames

- (CGRect)frameForWaterfallCellIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = self.itemWidth;
    CGFloat height = [[[self.itemsInSectionsHeights objectAtIndex:indexPath.section]
                       objectAtIndex:indexPath.item] floatValue];
    
    CGFloat topInset = self.itemInsets.top;
    for (NSInteger section = 0; section < indexPath.section; section++) {
        topInset += [[self.sectionsHeights objectAtIndex:section] integerValue];
    }

    NSInteger columnsHeights[self.columnsCount];
    for (NSInteger column = 0; column < self.columnsCount; column++) {
        columnsHeights[column] = self.headerHeight + self.itemInnerMargin;
    }
    
    for (NSInteger item = 0; item < indexPath.item; item++) {
        NSIndexPath *ip = [NSIndexPath indexPathForItem:item inSection:indexPath.section];
        NSInteger currentColumn = 0;
        for(NSInteger column = 0; column < self.columnsCount; column++) {
            if(columnsHeights[currentColumn] > columnsHeights[column]) {
                currentColumn = column;
            }
        }
                
        columnsHeights[currentColumn] += [[[self.itemsInSectionsHeights objectAtIndex:ip.section]
                                           objectAtIndex:ip.item] floatValue];
        columnsHeights[currentColumn] += self.itemInnerMargin;
    }
    
    NSInteger columnForCurrentItem = 0;
    for (NSInteger column = 0; column < self.columnsCount; column++) {
        if(columnsHeights[columnForCurrentItem] > columnsHeights[column]) {
            columnForCurrentItem = column;
        }
    }
    
    CGFloat originX = self.itemInsets.left + (columnForCurrentItem * (self.itemWidth) + columnForCurrentItem * self.itemInnerMargin);
    CGFloat originY =  columnsHeights[columnForCurrentItem] + topInset;
    
    return CGRectMake(originX, originY, width, height);
}

- (CGRect)frameForWaterfallHeaderAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = self.collectionView.bounds.size.width -
        self.itemInsets.left -
        self.itemInsets.right;
    CGFloat height = self.headerHeight;
    
    CGFloat originY = self.itemInsets.top;
    for (NSInteger i = 0; i < indexPath.section; i++) {
        originY += [[self.sectionsHeights objectAtIndex:i] floatValue];
    }
        
    CGFloat originX = self.itemInsets.left;    
    return CGRectMake(originX, originY, width, height);
}

- (CGRect) frameForWaterfallDecoration {
    CGSize size = [EIWaterfallDecorationReusableView defaultSize];
    CGFloat originX = floorf((self.collectionView.bounds.size.width - size.width) * 0.5f);
    CGFloat originY = -size.height - 30.0f;
    return CGRectMake(originX, originY, size.width, size.height);
}

@end
