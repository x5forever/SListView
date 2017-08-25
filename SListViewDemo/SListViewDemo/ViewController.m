//
//  ViewController.m
//  SListViewDemo
//
//  Created by x5 on 2017/1/12.
//  Copyright © 2017年 Xcution. All rights reserved.
//

#import "ViewController.h"
#import "SListView.h"

#define random(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define randomColor random(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

@interface ViewController ()<SListViewDataSource, SListViewDelegate>
@property (nonatomic, strong) SListView *listView;
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = @[randomColor,randomColor,randomColor,randomColor,randomColor];
    [self.view addSubview:self.listView];
}
- (IBAction)reload:(id)sender {
    self.dataSource = @[randomColor,randomColor,randomColor,randomColor,randomColor,randomColor,randomColor,randomColor];
    [self.listView reloadData];
}

#pragma mark - SListViewDataSource
- (CGFloat)listView:(SListView *)listView widthForColumnAtIndex:(NSInteger)index {
//    return CGRectGetWidth(self.view.frame);  // _fullScreenWidth = YES 
    return index % 2? 70:90;                 // _fullScreenWidth = NO
}
- (NSInteger)numberOfColumnsInListView:(SListView *)listView {
    return self.dataSource.count;
}
- (SListViewCell *)listView:(SListView *)listView viewForColumnAtIndex:(NSInteger)index {
    static NSString *identifier = @"ListViewCellIdentifier";
    SListViewCell *cell = [listView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[SListViewCell alloc] initWithIdentifier:identifier];
    }
    [self configureCell:cell atIndex:index];
    return cell;
}
- (void)configureCell:(SListViewCell *)cell atIndex:(NSInteger )index {
    cell.backgroundColor = _dataSource[index];
}
#pragma mark - SListViewDelegate
- (void)listView:(SListView *)listView didSelectColumnAtIndex:(NSInteger)index {
    NSLog(@"listView didSelectColumnAtIndex >> %ld",index);
}
- (void)listView:(SListView *)listView didScrollToColumn:(SRange)range {
//    NSLog(@"didScrollToColumn start:%ld  end:%ld",range.start,range.end);
}
#pragma mark - lazy init
- (SListView *)listView {
    if (!_listView) {
        _listView = [[SListView alloc] initWithFrame:CGRectMake(0, 150, CGRectGetWidth(self.view.frame), 200)];
        _listView.dataSource = self;
        _listView.delegate = self;
    }
    return _listView;
}
@end
