//
//  SLoopView.m
//  SListViewDemo
//
//  Created by x5 on 17/4/30.
//  Copyright © 2017年 Xcution. All rights reserved.
//

#import "SLoopView.h"
#import "SListView.h"
@interface SLoopView ()<SListViewDataSource, SListViewDelegate>
{
    struct {
        unsigned int didScroll           : 1;
        unsigned int didSelect           : 1;
    }_delegateFlags;
    
    SListView *_listView;
    NSInteger _count;
}
@end

@implementation SLoopView
- (id)initWithFrame:(CGRect) frame
{
    if (self = [super initWithFrame:frame]) {
        _listView = [[SListView alloc] initWithFrame:self.bounds];
        _listView.scrollView.showsHorizontalScrollIndicator = NO;
        _listView.scrollView.pagingEnabled = YES;
        _listView.delegate = self;
        [self addSubview:_listView];
    }
    return self;
}
- (void)setDelegate:(id<SLoopViewDelegate>)delegate
{
    _delegate = delegate;
    _delegateFlags.didScroll = [_delegate respondsToSelector:@selector(loopView:didScrollToColumn:)];
    _delegateFlags.didSelect = [_delegate respondsToSelector:@selector(loopView:didSelectColumnAtIndex:)];
}
- (void)setDataSource:(id<SLoopViewDataSource>)dataSource
{
    _dataSource = dataSource;
    _listView.dataSource = self;
    if (_count > 1) _listView.specifiedIndex = _count;
}
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    return [_listView dequeueReusableCellWithIdentifier:identifier];
}
- (void)reloadData
{
    [_listView reloadData];
    if (_count > 1) _listView.specifiedIndex = _count;
    else _listView.specifiedIndex = 0;
}
#pragma mark - SListViewDataSource
- (CGFloat)widthForColumnAtIndex:(NSInteger)index {
    return CGRectGetWidth(_listView.bounds);  // _fullScreenWidth = YES
}
- (NSInteger)numberOfColumnsInListView:(SListView *)listView {
    _count = [_dataSource numberOfColumnsInLoopView:self];
    if (_count <= 1) return _count;
    else return _count * 3;
}
- (SListViewCell *)listView:(SListView *)listView viewForColumnAtIndex:(NSInteger)index {
    return [_dataSource loopView:self viewForColumnAtIndex:index % _count];
}
#pragma mark - SListViewDelegate
- (void)listView:(SListView *)listView didSelectColumnAtIndex:(NSInteger)index {
    if (_delegateFlags.didSelect) [_delegate loopView:self didSelectColumnAtIndex:index % _count];
}
- (void)listView:(SListView *)listView didScrollToColumn:(SRange)range {
    if (_delegateFlags.didScroll) [_delegate loopView:self didScrollToColumn:range.start % _count];
}
// 滚动完毕就会调用（如果不是人为拖拽scrollView导致滚动完毕，才会调用这个方法）
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollViewDidEndDecelerating:scrollView];
}
// 当滚动减速时调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger page = offsetX / scrollView.bounds.size.width;
    if (page == 0) {
        _listView.specifiedIndex = _count;
    }else if (page == _count * 3 - 1){
        _listView.specifiedIndex = _count - 1;
    }
}
// 手指开始拖动时调用
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //移除定时器
}
@end
