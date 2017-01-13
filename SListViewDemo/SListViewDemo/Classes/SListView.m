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

@implementation SListView
{
    CGFloat _preOffsetX;
    NSNumberFormatter *_formatter;
    
    struct {
        unsigned int didScroll           : 1;
        unsigned int didEndDecelerating  : 1;
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
        _formatter = [[NSNumberFormatter alloc] init];
        [_formatter setPositiveFormat:@"0"];
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame) + kSpace, CGRectGetHeight(frame))];
        [_scrollView flashScrollIndicators];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        [self addSubview:_scrollView];
        _specificIndex = 0;
    }
    return self;
}
- (void)setDelegate:(id<SListViewDelegate>)delegate
{
    _delegate = delegate;
    _delegateFlags.didScroll = [delegate respondsToSelector:@selector(listViewDidScroll:)];
    _delegateFlags.didEndDecelerating = [delegate respondsToSelector:@selector(listViewDidEndDeceleratingAtIndex:)];
}
- (void) setDataSource:(id<SListViewDataSource>)dataSource
{
    _dataSource = dataSource;
    _dataSourceFlags.numberOfColumns = [dataSource respondsToSelector:@selector(numberOfColumnsInListView:)];
    _dataSourceFlags.widthForColumn = [dataSource respondsToSelector:@selector(widthForColumnAtIndex:)];
    
    [self loadData];
}
- (void)setShowsHorizontalScrollIndicator:(BOOL)showsHorizontalScrollIndicator {
    _showsHorizontalScrollIndicator = showsHorizontalScrollIndicator;
    _scrollView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator;
}
- (void)setSpecificIndex:(NSInteger)specificIndex {
    _specificIndex = specificIndex;
    [self loadData];
}
- (void) loadData
{
    if (_dataSourceFlags.numberOfColumns) {
        _columns = [_dataSource numberOfColumnsInListView:self];
        if (_columns <= 0) {
            return;
        }
        CGFloat left = 0;
        NSInteger end = ceilf(CGRectGetWidth(self.frame)/[_dataSource widthForColumnAtIndex:_specificIndex]) - 1;
        if (end < 0 ) end = 0;
        _visibleRange = SRangeMake(_specificIndex, _specificIndex + end);
        _columnRects = [NSMutableArray arrayWithCapacity:_columns];
        for (int index = 0; index < _columns; index ++) {
            CGFloat width = _height;
            if (_dataSourceFlags.widthForColumn) {
                width = [_dataSource widthForColumnAtIndex:index];
            }
            
            CGRect rect = CGRectMake(left, 0, width, _height);
            
            [_columnRects addObject:NSStringFromCGRect(rect)];
            left += width + kSpace;
        }
        _scrollView.contentSize = CGSizeMake(left, _height);
    }

    if (!_visibleListCells) {
        _visibleListCells = [NSMutableArray arrayWithCapacity:ceilf(CGRectGetWidth(self.frame)/[_dataSource widthForColumnAtIndex:_specificIndex])+1];
    }
    
    
    CGRect specificRect = CGRectFromString([_columnRects objectAtIndex:_specificIndex]);
    _scrollView.contentOffset = CGPointMake(CGRectGetMinX(specificRect), 0);
    CGRect rect = [_scrollView visibleRect];
    NSUInteger index = _visibleRange.start;
    CGFloat left = 0;
    while (left <= rect.size.width && index <= _columns -1) {
        CGRect frame = CGRectFromString([_columnRects objectAtIndex:index]);
        [self requestCellWithIndex:index direction:SDirectionTypeLeft];
        left += frame.size.width;
        if (left <= rect.size.width) {
            index ++;
        }
    }
    if (index == _columns) {
        index--;
    }
    _visibleRange.end = index;
    
}

- (void) reloadData {
    [self loadData];
}

- (SListViewCell *) requestCellWithIndex:(NSInteger) index direction:(SDirectionType) direction {
    CGRect frame = CGRectFromString([_columnRects objectAtIndex:index]);
    SListViewCell * cell = [_dataSource listView:self viewForColumnAtIndex:index];
    cell.frame = frame;
    cell.tag = index;
    [_scrollView addSubview:cell];
    if (direction == SDirectionTypeLeft) {
        [_visibleListCells addObject:cell];
    }else if(direction == SDirectionTypeRight) {
        [_visibleListCells insertObject:cell atIndex:0];
    }
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

/// Cell 的复用
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
        _reusableListCells = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    NSMutableArray * cells = [_reusableListCells valueForKey:identifier];
    if (!cells) {
        cells  = [[NSMutableArray alloc] initWithCapacity:ceilf(CGRectGetWidth(self.frame)/[_dataSource widthForColumnAtIndex:_specificIndex])+1];
        [_reusableListCells setValue:cells forKey:identifier];
    }
    [cells addObject:reuseView];
    [_visibleListCells removeObject:reuseView];
    [reuseView removeFromSuperview];
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float decimal = scrollView.contentOffset.x / [_dataSource widthForColumnAtIndex:_visibleRange.start];
    NSInteger index = [[_formatter stringFromNumber:[NSNumber numberWithFloat:decimal]] integerValue] ;
    if (scrollView.contentOffset.x > 0 && scrollView.contentOffset.x < scrollView.contentSize.width) {
        if (_delegateFlags.didScroll) {
            [_delegate listViewDidScroll:index];
        }
    }
    CGRect tempRect = [scrollView visibleRect];
    CGFloat offsetX = tempRect.origin.x - _visibleRect.origin.x;
    _visibleRect = tempRect;
    [self reLayoutSubViewsWithOffset:offsetX];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _preOffsetX = scrollView.contentOffset.x;
    if (_delegateFlags.didEndDecelerating) {
        [_delegate listViewDidEndDeceleratingAtIndex:_scrollView.contentOffset.x / _scrollView.frame.size.width];
    }
}

@end
