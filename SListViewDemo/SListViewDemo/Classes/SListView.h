//
//  SListView.h
//  宜人贷借款
//
//  Created by x5 on 14-6-27.
//  Copyright (c) 2014年  Creditease. All rights reserved.
//

#import "SListViewCell.h"
#import <QuartzCore/QuartzCore.h>

@class SListView;
/// 定义一种结构体，用来表示区间。表示一个 从 几到几 的概念
typedef struct _SRange{
    NSInteger start;
    NSInteger end;
} SRange;

NS_INLINE SRange SRangeMake(NSInteger start, NSInteger end) {
    SRange range;
    range.start = start;
    range.end = end;
    return range;
}

NS_INLINE BOOL InRange(SRange r,NSInteger i) {
    return (r.start <= i) && (r.end >= i);
}

typedef enum _SDirection {
    SDirectionTypeLeft,
    SDirectionTypeRight
} SDirectionType;

@protocol SListViewDelegate <NSObject, UIScrollViewDelegate>
@optional
- (void)listViewDidScroll:(NSInteger)index;
- (void)listViewDidEndDeceleratingAtIndex:(NSUInteger)index;
@end

@protocol SListViewDataSource <NSObject>

@optional
- (NSInteger) numberOfColumnsInListView:(SListView *) listView;
- (CGFloat) widthForColumnAtIndex:(NSInteger) index;
- (SListViewCell *) listView:(SListView *)listView viewForColumnAtIndex:(NSInteger) index;
@end

@interface UIScrollView (Rect)
- (CGRect) visibleRect;
@end

@interface SListView : UIView <NSCoding, UIScrollViewDelegate> {
    /// ListCell 个数
    NSInteger _columns;
    /// 每个SListViewCell 的高度
    CGFloat _height;
    /// 所有的SListViewCell 的frame
    NSMutableArray * _columnRects;
    /// 可见的column范围
    SRange _visibleRange;
    /// scrollView 的可见区域
    CGRect _visibleRect;
    /// 可见的SListViewCell;
    NSMutableArray * _visibleListCells;
    /// 可重用的ListCells {identifier:[cell1,cell2]}
    NSMutableDictionary * _reusableListCells;
}
@property (nonatomic,assign) id<SListViewDelegate> delegate;
@property (nonatomic,assign) id<SListViewDataSource> dataSource;
@property (nonatomic, readonly) UIScrollView * scrollView;
@property (nonatomic, assign) NSInteger specificIndex;
@property (nonatomic, assign) BOOL showsHorizontalScrollIndicator;
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (void) reloadData;

@end
