//
//  SListView.h
//  SListViewDemo
//
//  Created by x5 on 14-6-27.
//  Copyright (c) 2014年  Creditease. All rights reserved.
//  V1.0.1

#import "SListViewCell.h"

@class SListView;
// 定义一种结构体，用来表示区间。表示一个 从 几到几 的概念
typedef struct _SRange{
    NSInteger start;
    NSInteger end;
} SRange;

// 创建结构体 SRange，结构体中保存 start，end
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

@interface UIScrollView (Rect)
- (CGRect) visibleRect;
@end

@protocol SListViewDelegate <NSObject,UIScrollViewDelegate>
@optional
- (void)listView:(SListView *)listView didScrollToColumn:(SRange)range;
- (void)listView:(SListView *)listView didSelectColumnAtIndex:(NSInteger)index;
@end

@protocol SListViewDataSource <NSObject>
@optional
- (NSInteger)numberOfColumnsInListView:(SListView *)listView;
- (CGFloat)listView:(SListView *)listView widthForColumnAtIndex:(NSInteger) index;
- (SListViewCell *)listView:(SListView *)listView viewForColumnAtIndex:(NSInteger)index;
@end

@interface SListView : UIView <NSCoding, UIScrollViewDelegate>

@property (nonatomic, weak) id <SListViewDelegate>    delegate;
@property (nonatomic, weak) id <SListViewDataSource>  dataSource;
@property (nonatomic, assign) NSInteger               specifiedIndex; //default is 0, 指定当前的index. 注意：当且仅当 _isFullScreenWidth == YES 时有效
@property (nonatomic, assign) CGFloat                 listViewCellSpace; //default is 0
@property (nonatomic, strong, readonly) UIScrollView *scrollView;

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (SListViewCell *)cellForColumnAtIndex:(NSInteger)index; // returns nil if cell is not visible or index is out of range
- (void)reloadData;
@end
