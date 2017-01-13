//
//  ViewController.m
//  SListViewDemo
//
//  Created by x5 on 2017/1/12.
//  Copyright © 2017年 Xcution. All rights reserved.
//

#import "ViewController.h"
#import "SListView.h"
#import "ListViewPage.h"

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
#pragma mark - SListViewDataSource
- (CGFloat)widthForColumnAtIndex:(NSInteger)index {
    return CGRectGetWidth(self.view.frame)/2;
}

- (NSInteger)numberOfColumnsInListView:(SListView *)listView {
    return self.dataSource.count;
}

- (SListViewCell *)listView:(SListView *)listView viewForColumnAtIndex:(NSInteger)index {
    static NSString *identifier = @"ListViewPageIdentifier";
    ListViewPage *cell = (ListViewPage *)[listView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[ListViewPage alloc] initWithIdentifier:identifier];
    }
    [self configureCell:cell atIndex:index];
    return cell;
}
- (void)configureCell:(SListViewCell *)cell atIndex:(NSInteger )index {
    cell.backgroundColor = _dataSource[index];
}
#pragma mark - SListViewDelegate
- (void)listViewDidScroll:(NSInteger)index {
    NSLog(@"%ld",index);
}


- (SListView *)listView {
    if (!_listView) {
        _listView = [[SListView alloc] initWithFrame:CGRectMake(0, 200, CGRectGetWidth(self.view.frame), 200)];
        _listView.dataSource = self;
        _listView.delegate = self;
        _listView.specificIndex = 1;
    }
    return _listView;
}
@end
