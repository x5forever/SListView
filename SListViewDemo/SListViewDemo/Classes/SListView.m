//
//  SListView.m
//  宜人贷借款
//
//  Created by x5 on 14-6-27.
//  Copyright (c) 2014年  Creditease. All rights reserved.
//
//  仿iPhone天气效果，添加间隔kSpace by x5 , 2014-12-23.
//  添加缓存 by x5 , 2015-1-20.
//

#import "SListView.h"

static const CGFloat kSpace = 0.0f;

@implementation UIScrollView (Rect)
- (CGRect) visibleRect {
    CGRect rect;
    rect.origin = self.contentOffset;
    rect.size = self.bounds.size;
	return rect;
}
@end

@interface SListView () {
    // ListCell 个数
    NSInteger _columns;
    // 每个SListViewCell 的高度
    CGFloat _height;
    // 所有的SListViewCell 的frame
    NSMutableArray * _columnRects;
    // 可见的column范围
    SRange _visibleRange;
    // scrollView 的可见区域
    CGRect _visibleRect;
    // 可见的SListViewCell;
    NSMutableArray * _visibleListCells;
    // 可重用的ListCells {identifier:[cell1,cell2]}
    NSMutableDictionary * _reusableListCells;
    // 所以子视图cell 的 width 恒等于 _scrollView 的 width
    BOOL _fullScreenWidth;
    // _scrollView.contentOffset 会触发 scrollViewDidScroll: 需要先屏蔽掉
    BOOL _scrollViewEnabel;
}
@end

@implementation SListView
{
    struct {
        unsigned int didScroll           : 1;
        unsigned int didSelect           : 1;
    }_delegateFlags;
    
    struct {
        unsigned int numberOfColumns     : 1;
        unsigned int widthForColumn      : 1;
    }_dataSourceFlags;
    
}

@synthesize scrollView = _scrollView;
@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;

- (id)initWithFrame:(CGRect) frame {
    self = [super initWithFrame:frame];
    if (self) {
        _height = CGRectGetHeight(frame);
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame)+kSpace, _height)];
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    return self;
}
- (void)setDelegate:(id<SListViewDelegate>)delegate
{
    _delegate = delegate;
    _delegateFlags.didScroll = [delegate respondsToSelector:@selector(listView:didScrollToColumn:)];
    _delegateFlags.didSelect = [delegate respondsToSelector:@selector(listView:didSelectColumnAtIndex:)];
}
- (void) setDataSource:(id<SListViewDataSource>)dataSource
{
    _dataSource = dataSource;
    _dataSourceFlags.numberOfColumns = [dataSource respondsToSelector:@selector(numberOfColumnsInListView:)];
    _dataSourceFlags.widthForColumn = [dataSource respondsToSelector:@selector(listView:widthForColumnAtIndex:)];
    
    [self loadData];
}
- (void)setSpecifiedIndex:(NSInteger)specifiedIndex
{
    _specifiedIndex = specifiedIndex;
    if (_dataSource && _fullScreenWidth) {
        [self loadData];
    }
}
- (void) reloadData {
    [self loadData];
}
- (void) loadData
{
    _fullScreenWidth = YES;
    if (_dataSourceFlags.numberOfColumns) {
        _visibleRect = CGRectZero;
        _columns = [_dataSource numberOfColumnsInListView:self];
        if (_columns <= 0) return;

        if (!_columnRects) {
            _columnRects = [NSMutableArray arrayWithCapacity:_columns];
        }else{
            [_columnRects removeAllObjects];
        }
        
        CGFloat left = 0;
        for (int index = 0; index < _columns; index ++) {
            CGFloat width = _height;
            if (_dataSourceFlags.widthForColumn) {
                width = [_dataSource listView:self widthForColumnAtIndex:index];
            }
            if (_fullScreenWidth) { // 以下判断 cell 是否为全屏显示
                _fullScreenWidth = CGRectGetWidth(_scrollView.frame) == width;
            }
            CGRect rect = CGRectMake(left, 0, width, _height);
            [_columnRects addObject:NSStringFromCGRect(rect)];
            left += width + kSpace;
        }
        _scrollViewEnabel = NO;
        _scrollView.contentSize = CGSizeMake(left, _height);
        _scrollView.contentOffset = CGPointMake(0 + CGRectGetWidth(_scrollView.frame)*_specifiedIndex*_fullScreenWidth , 0);
        _scrollViewEnabel = YES;
    }
    
    if (!_visibleListCells) {
        _visibleListCells = [NSMutableArray arrayWithCapacity:2];
    }else{
        while (_visibleListCells.count > 0) {
            SListViewCell *cell = _visibleListCells[0];
            [self inqueueReusableWithView:cell];
        }
    }
    _visibleRange = SRangeMake(0 + _specifiedIndex*_fullScreenWidth, 0 + _specifiedIndex*_fullScreenWidth);
    CGRect rect = [_scrollView visibleRect];
    NSUInteger index = _visibleRange.start;
    CGFloat left = 0;
    while (left < rect.size.width && index < _columns) {
        CGRect frame = CGRectFromString([_columnRects objectAtIndex:index]);
        [self requestCellWithIndex:index direction:SDirectionTypeLeft];
        left += frame.size.width;
        if (left < rect.size.width) {
            index ++;
        }
    }
    if (index == _columns) {
        index--;
    }
    _visibleRange.end = index;
    
}
- (SListViewCell *) requestCellWithIndex:(NSInteger) index direction:(SDirectionType) direction {
    CGRect frame = CGRectFromString([_columnRects objectAtIndex:index]);
    SListViewCell * cell = [_dataSource listView:self viewForColumnAtIndex:index];
    cell.frame = frame;
    cell.tag = index;
    [_scrollView addSubview:cell];
    [_scrollView sendSubviewToBack:cell];
    [cell addTarget:self action:@selector(didSelect:) forControlEvents:UIControlEventTouchUpInside];
    if (direction == SDirectionTypeLeft) {
        [_visibleListCells addObject:cell];
    }else if(direction == SDirectionTypeRight) {
        [_visibleListCells insertObject:cell atIndex:0];
    }
//    NSLog(@"_visibleListCells count >> %ld",_visibleListCells.count);
    return cell;
}
- (void) reLayoutSubViewsWithOffset:(CGFloat) offset {
    NSInteger start = _visibleRange.start;
    NSInteger end = _visibleRange.end;
    CGRect frame = CGRectFromString([_columnRects objectAtIndex:start]);
    CGRect frame1 = CGRectFromString([_columnRects objectAtIndex:end]);
    // 向左滑动
    if (offset > 0) {
        // 判断如果 可见区域的第一个移除区域外，则放进 可复用池里面。允许可复用
        if ((_visibleRect.origin.x) >= (frame.origin.x + frame.size.width)) {
            SListViewCell * cell = (SListViewCell *) [_visibleListCells objectAtIndex:0];
            [self inqueueReusableWithView:cell];
            start += 1;
            _visibleRange.start = start;
        }
        // 如果最后一个的末尾被滚进区域，则加载下一个
        if ((_visibleRect.origin.x + _visibleRect.size.width) >= (frame1.origin.x + frame1.size.width)) {
            end += 1;
            if (end < _columns) {
                [self requestCellWithIndex:end direction:SDirectionTypeLeft];
                _visibleRange.end = end;
            }
        }
    }
    // 向右滑动
    else {
        // 判断如果 可见区域的最后一个移除区域外，则放进 可复用池里面。允许可复用
        if ( frame1.origin.x >= (_visibleRect.origin.x + _visibleRect.size.width) ) {
            SListViewCell * cell = (SListViewCell *) [_visibleListCells lastObject];
            [self inqueueReusableWithView:cell];
            end -= 1;
            _visibleRange.end = end;
            
        }
        if (frame.origin.x >= _visibleRect.origin.x) {
            start -= 1;
            if (start >= 0) {
                [self requestCellWithIndex:start direction:SDirectionTypeRight];
                _visibleRange.start = start;
            }
        }
    }
}

// Cell 的复用
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    SListViewCell * cell = nil;
    NSMutableArray * reuseCells = [_reusableListCells objectForKey:identifier];
    if ([reuseCells count] > 0) {
        cell = [reuseCells objectAtIndex:0];
        [reuseCells removeObject:cell];
    }
    return cell;
}

- (void)inqueueReusableWithView:(SListViewCell *) reuseView {
    NSString * identifier = reuseView.identifier;
    if (!_reusableListCells) {
        _reusableListCells = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    NSMutableArray * cells = [_reusableListCells valueForKey:identifier];
    if (!cells) {
        cells  = [[NSMutableArray alloc] initWithCapacity:2];
        [_reusableListCells setValue:cells forKey:identifier];
    }
    [cells addObject:reuseView];
    [_visibleListCells removeObject:reuseView];
    [reuseView removeFromSuperview];
}
- (SListViewCell *)cellForColumnAtIndex:(NSInteger)index {
    SListViewCell *cell = nil;
    if (InRange(_visibleRange, index)) {
        cell = _visibleListCells[index - _visibleRange.start];
    }
    return cell;
}
#pragma mark - call SListViewDelegate
- (void)didSelect:(SListViewCell *)cell {
    if (_delegateFlags.didSelect) {
        [_delegate listView:self didSelectColumnAtIndex:cell.tag];
    }
}
// ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (_delegateFlags.didScroll) {
        if (_fullScreenWidth) { // 当所以cell宽度恒等于_scrollView宽度时，显示出_scrollView 1/2 以上宽度即为已显示
            float decimal = scrollView.contentOffset.x / CGRectGetWidth(_scrollView.frame);
            NSInteger index = roundf(decimal); // 四舍五入
            if (scrollView.contentOffset.x >= 0 && scrollView.contentOffset.x <= scrollView.contentSize.width && index < _columns) {
                [_delegate listView:self didScrollToColumn:SRangeMake(index, index)];
            }
        }else {
            [_delegate listView:self didScrollToColumn:_visibleRange];
        }
    }
    
    if (!_scrollViewEnabel) return;
    
    CGRect tempRect = [scrollView visibleRect];
    CGFloat offsetX = tempRect.origin.x - _visibleRect.origin.x;
    _visibleRect = tempRect;
    [self reLayoutSubViewsWithOffset:offsetX];
    
    
}
- (BOOL)respondsToSelector:(SEL)aSelector {
    BOOL hasResponds = [super respondsToSelector:aSelector];
    if(hasResponds == NO) hasResponds = [_delegate respondsToSelector:aSelector];
    return hasResponds;
}
- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector {
    NSMethodSignature* methodSign = [super methodSignatureForSelector:selector];
    if(methodSign == nil) methodSign = [(id)_delegate methodSignatureForSelector:selector];
    return methodSign;
}
- (void)forwardInvocation:(NSInvocation*)invocation {
    [invocation invokeWithTarget:_delegate];
}
@end
