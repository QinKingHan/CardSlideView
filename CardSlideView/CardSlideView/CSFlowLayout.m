//
//  CSFlowLayout.m
//  CardSlideView
//
//  Created by 鑫鑫 on 2017/5/2.
//  Copyright © 2017年 xinxin. All rights reserved.
//

#import "CSFlowLayout.h"
/*
 他们彬彬有礼，体面正派，聪明伶俐，魅力十足……那的确是一种麻木，
 一种可敬的、急于为社会所用的、经过绝妙拿捏的、然而却十分冷淡呆板的优雅与得体
 
 */
#define SCREENWITH   [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height
//为垂直缩放除以系数
static CGFloat const ActiveDistance = 350;
//越大，缩放越大。
static CGFloat const ScaleFactor = 0.1;

@implementation CSFlowLayout

-(id)init{
    self = [super init];
    if (self) {
        _move_x = 0.0;
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minimumLineSpacing = 20.0;
        self.sectionInset = UIEdgeInsetsMake(0,30, 0,30);
    }
    return self;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    proposedContentOffset.y = 0.0;
    if (_isPagingEnabled) {
        proposedContentOffset.x = [self PageMove:proposedContentOffset];
    }else{
        proposedContentOffset.x = [self SMove:proposedContentOffset velocity:velocity];
    }
    return proposedContentOffset;
}


-(CGFloat)PageMove:(CGPoint)proposedContentOffset{
    CGFloat set_x =  proposedContentOffset.x;
    
    if (set_x > _move_x) {
        _move_x += SCREENWITH - self.minimumLineSpacing * 2;
    }else if(set_x < _move_x){
        _move_x -= SCREENWITH - self.minimumLineSpacing * 2;
    }
    set_x = _move_x;
    return set_x;
}

-(CGFloat)SMove:(CGPoint)proposedContentOffset velocity :(CGPoint)velocity{
    
    CGFloat offSetAdjustment = MAXFLOAT;
    CGFloat horizontalCenter = (CGFloat) (proposedContentOffset.x + (self.collectionView.bounds.size.width / 2.0));
    
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    
    NSArray *array = [self layoutAttributesForElementsInRect:targetRect];
    
    UICollectionViewLayoutAttributes *currentAttributes;
    
    for (UICollectionViewLayoutAttributes *layoutAttributes in array)
    {
        if(layoutAttributes.representedElementCategory == UICollectionElementCategoryCell)
        {
            CGFloat itemHorizontalCenter = layoutAttributes.center.x;
            if (ABS(itemHorizontalCenter - horizontalCenter) <  ABS(offSetAdjustment))
            {
                currentAttributes   = layoutAttributes;
                offSetAdjustment    = itemHorizontalCenter - horizontalCenter;
            }
        }
    }
    
    CGFloat nextOffset          = proposedContentOffset.x + offSetAdjustment;
    
    proposedContentOffset.x     = nextOffset;
    
    CGFloat deltaX              = proposedContentOffset.x - self.collectionView.contentOffset.x;
    CGFloat velX                = velocity.x;
    
    if(deltaX == 0.0 || velX == 0 || (velX >  0.0  &&  deltaX >  0.0) || (velX <  0.0 &&  deltaX <  0.0)) {
        
    } else if(velocity.x >  0.0) {
        for (UICollectionViewLayoutAttributes *layoutAttributes in array)
        {
            if(layoutAttributes.representedElementCategory == UICollectionElementCategoryCell)
            {
                CGFloat itemHorizontalCenter = layoutAttributes.center.x;
                if (itemHorizontalCenter >  proposedContentOffset.x) {
                    proposedContentOffset.x = nextOffset + (currentAttributes.frame.size.width / 2) + (layoutAttributes.frame.size.width / 2);
                    break;
                }
            }
        }
    } else if(velocity.x <=  0.0) {
        for (UICollectionViewLayoutAttributes *layoutAttributes in array)
        {
            if(layoutAttributes.representedElementCategory == UICollectionElementCategoryCell)
            {
                CGFloat itemHorizontalCenter = layoutAttributes.center.x;
                if (itemHorizontalCenter >  proposedContentOffset.x) {
                    proposedContentOffset.x = nextOffset - ((currentAttributes.frame.size.width / 2) + (layoutAttributes.frame.size.width / 2));
                    break;
                }
            }
        }
    }
    
    if (proposedContentOffset.x == -0.0) {
        proposedContentOffset.x = 0.0;
        
    }
    return proposedContentOffset.x;
    
}

-(void)setPagingEnabled:(BOOL)isPagingEnabled{
    _isPagingEnabled = isPagingEnabled;
}



-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    
    for (UICollectionViewLayoutAttributes* attributes in array) {
        CGFloat distance = CGRectGetMidX(visibleRect) - attributes.center.x;
        CGFloat normalizedDistance = distance / ActiveDistance;
        CGFloat zoom = 1 + ScaleFactor*(1 - ABS(normalizedDistance));
        attributes.transform3D = CATransform3DMakeScale(1.0, zoom, 1.0);
        attributes.zIndex = 1;
    }
    return array;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}
@end
