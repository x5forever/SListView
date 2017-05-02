//
//  SLoopView.m
//  SListViewDemo
//
//  Created by x5 on 17/4/30.
//  Copyright © 2017年 Xcution. All rights reserved.
//

#import "SLoopView.h"
#import "SListView.h"
#import "SWeakTimerObject.h"

@interface SLoopView ()<SListViewDataSource, SListViewDelegate>
{
    struct {
        unsigned int didScroll           : 1;
        unsigned int didSelect           : 1;
    }_delegateFlags;
    
    SListView *_listView;
    NSInteger _realCount;
    NSTimeInterval _timeInterval;
}
@property (nonatomic, weak) NSTimer *timer;
@end

@implementation SLoopView
- (id)initWithFrame:(CGRect)frame loopInterval:(NSTimeInterval)ti
{
    if (self = [self initWithFrame:frame]) {
        _timeInterval = ti;
    }
    return self;
}
- (id)initWithFrame:(CGRect) frame
{
    if (self = [super initWithFrame:frame]) {
        _listView = [[SListView alloc] initWithFrame:self.bounds];
        _listView.scrollView.showsHorizontalScrollIndicator = NO;
        _listView.scrollView.pagingEnabled = YES;
        _listView.delegate = self;
        [self addSubview:_listView];
        _timeInterval = 0;
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
    [self reloadData];
}
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    return [_listView dequeueReusableCellWithIdentifier:identifier];
}
- (void)reloadData
{
    [self removeTimer];
    _realCount = [_dataSource numberOfColumnsInLoopView:self];
    if (_realCount > 1) _listView.specifiedIndex = _realCount;
    else _listView.specifiedIndex = 0;
    // 添加定时器
    if (_realCount > 1 && _timeInterval > 0) {
        [self addTimer];
    }
}
#pragma mark - SListViewDataSource
- (CGFloat)widthForColumnAtIndex:(NSInteger)index {
    return CGRectGetWidth(_listView.bounds);  // _fullScreenWidth = YES
}
- (NSInteger)numberOfColumnsInListView:(SListView *)listView {
    if (_realCount > 1) return _realCount * 3;
    else return _realCount;
}
- (SListViewCell *)listView:(SListView *)listView viewForColumnAtIndex:(NSInteger)index {
    return [_dataSource loopView:self viewForColumnAtIndex:index % _realCount];
}
#pragma mark - SListViewDelegate
- (void)listView:(SListView *)listView didSelectColumnAtIndex:(NSInteger)index {
    if (_delegateFlags.didSelect) [_delegate loopView:self didSelectColumnAtIndex:index % _realCount];
}
- (void)listView:(SListView *)listView didScrollToColumn:(SRange)range {
    if (_delegateFlags.didScroll) [_delegate loopView:self didScrollToColumn:range.start % _realCount];
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
        _listView.specifiedIndex = _realCount;
    }else if (page == _realCount * 3 - 1){
        _listView.specifiedIndex = _realCount - 1;
    }
    if (_timeInterval > 0) [self addTimer];
}
// 手指开始拖动时调用
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //移除定时器
    [self removeTimer];
    
    // 快速拖动时，让页面连续
    CGFloat offsetX = scrollView.contentOffset.x;
    if (offsetX < CGRectGetWidth(scrollView.frame)/2.0) {
        _listView.specifiedIndex = _realCount;
    }
    else if (offsetX > CGRectGetWidth(scrollView.frame) * (_realCount * 3 - 1 - 1/2)){
        _listView.specifiedIndex = _realCount - 1;
    }
}
// 切换到下一张
- (void)nextCell {
    [_listView.scrollView setContentOffset:CGPointMake(_listView.scrollView.contentOffset.x + CGRectGetWidth(_listView.frame), 0) animated:YES];
}
// 添加定时器
- (void)addTimer {
    if (_timer) return;
    _timer = [SWeakTimerObject scheduledTimerWithTimeInterval:_timeInterval target:self selector:@selector(nextCell) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}
// 移除定时器
- (void)removeTimer {
    if (_timer != nil) {
        [_timer invalidate];
        _timer = nil;
    }
}
- (void)dealloc {
    [self removeTimer];
}
@end
