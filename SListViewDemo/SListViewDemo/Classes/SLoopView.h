//
//  SLoopView.h
//  SListViewDemo
//
//  Created by x5 on 17/4/30.
//  Copyright © 2017年 Xcution. All rights reserved.
//

//  SLoopView 是在 SListView 的基础上，重新封装了一层

#import "SListViewCell.h"

@class SLoopView;

@protocol SLoopViewDelegate <NSObject>
@optional
- (void)loopView:(SLoopView *)loopView didScrollToColumn:(NSInteger)index;
- (void)loopView:(SLoopView *)loopView didSelectColumnAtIndex:(NSInteger)index;
@end

@protocol SLoopViewDataSource <NSObject>
@optional
- (NSInteger)numberOfColumnsInLoopView:(SLoopView *)loopView;
- (SListViewCell *)loopView:(SLoopView *)loopView viewForColumnAtIndex:(NSInteger)index;
@end

@interface SLoopView : UIView

@property (nonatomic, weak) id <SLoopViewDelegate>    delegate;
@property (nonatomic, weak) id <SLoopViewDataSource>  dataSource;
- (id)initWithFrame:(CGRect)frame loopInterval:(NSTimeInterval)ti; // ti must be > 0 , otherwise it's invalid
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (void)reloadData;
@end
