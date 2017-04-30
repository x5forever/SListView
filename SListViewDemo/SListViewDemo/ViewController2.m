//
//  ViewController2.m
//  SListViewDemo
//
//  Created by x5 on 17/4/30.
//  Copyright © 2017年 Xcution. All rights reserved.
//

#import "ViewController2.h"
#import "SLoopView.h"

#define random(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define randomColor random(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

@interface ViewController2 ()<SLoopViewDelegate,SLoopViewDataSource>
@property (nonatomic, strong) SLoopView *loopView;
@property (nonatomic, strong) NSArray *dataSource;

@property (strong, nonatomic) IBOutlet UILabel *showLabel;
@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = @[randomColor,randomColor,randomColor];
    [self.view addSubview:self.loopView];
    _showLabel.text = @"0";
}
- (NSInteger)numberOfColumnsInLoopView:(SLoopView *)loopView
{
    return self.dataSource.count;
}
#pragma mark - SLoopViewDataSource
- (SListViewCell *)loopView:(SLoopView *)loopView viewForColumnAtIndex:(NSInteger)index
{
    static NSString *identifier = @"LoopViewCellIdentifier";
    SListViewCell *cell = [loopView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[SListViewCell alloc] initWithIdentifier:identifier];
    }
    [self configureCell:cell atIndex:index];
    return cell;
}
- (void)configureCell:(SListViewCell *)cell atIndex:(NSInteger )index {
    cell.backgroundColor = _dataSource[index];
}
#pragma mark - SLoopViewDelegate
- (void)loopView:(SLoopView *)loopView didScrollToColumn:(NSInteger)index
{
    _showLabel.text = [NSString stringWithFormat:@"%ld",index];
}
- (void)loopView:(SLoopView *)loopView didSelectColumnAtIndex:(NSInteger)index
{
    NSLog(@"didSelectColumnAtIndex >> %ld",index);
}
#pragma mark - lazy init
- (SLoopView *)loopView
{
    if (!_loopView) {
        _loopView = [[SLoopView alloc] initWithFrame:CGRectMake(0, 200, CGRectGetWidth(self.view.frame), 200)];
        _loopView.dataSource = self;
        _loopView.delegate = self;
    }
    return _loopView;
}
@end
