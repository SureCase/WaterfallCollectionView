WaterfallCollectionView
=======================

WaterfallCollectionView is custom layout for UICollectionView, based on Pinterest style. It supports (sticky or not) header supplementary view and decoration view.

...and now It's in development phase. :)

Sample usage
------------

Setup FRGWaterfallCollectionViewLayout as UICollectionView layout in you view controller.

``` objective-c
/*...*/
FRGWaterfallCollectionViewLayout *cvLayout = [[FRGWaterfallCollectionViewLayout alloc] init];
    cvLayout.delegate = self;
    
    cvLayout.itemWidth = 140.0f;
    cvLayout.topInset = 10.0f;
    cvLayout.bottomInset = 10.0f;
    cvLayout.stickyHeader = YES;
    
    [self.cv setCollectionViewLayout:cvLayout];		//cv is UICollectionView property
/*...*/
```

If you want to show section header you should implement delegate method

``` objective-c
- (CGFloat) collectionView:(UICollectionView *)collectionView
                    layout:(FRGWaterfallCollectionViewLayout *)collectionViewLayout
heightForHeaderAtIndexPath:(NSIndexPath *)indexPath;
```

Screenshots
------------
![Sections](https://raw.github.com/frogermcs/WaterfallCollectionView/master/Screenshots/Screenshot-1.png)

![Decoration view](https://raw.github.com/frogermcs/WaterfallCollectionView/master/Screenshots/Screenshot-2.png)

![Horizontal orientation](https://raw.github.com/frogermcs/WaterfallCollectionView/master/Screenshots/Screenshot-3.png)

![Sticky header](https://raw.github.com/frogermcs/WaterfallCollectionView/master/Screenshots/Screenshot-4.png)

