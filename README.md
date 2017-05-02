# SListView
* the custom tableView of horizontal sliding and support carousel figure

# Function
* 水平滑动的自定义tableView
* 新增 SLoopView 支持无限轮播
* 实现了复用机制
* 有待继续完善“垂直滑动”、“卡片样式”

# Add to the Podfile
```objc 
pod 'SListView','~>0.3.0'
```
# How to use SListView
```objc 
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
- (CGFloat)widthForColumnAtIndex:(NSInteger)index { 
    return index % 2? 70:90; 
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
    NSLog(@"didScrollToColumn start:%ld  end:%ld",range.start,range.end);
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
```

## Update
* V0.3.0 <br> 
  1.新增 SLoopView : 支持无限轮播<br>
  2.优化 SListView
* V0.2.0 <br> 
  1.变宽<br>
  2.新增&修改方法<br>
  3.优化逻辑
* V0.1.1 <br> 
  1.修复reload bug,优化复用机制
* V0.1.0 <br> 
  1.首次上传
