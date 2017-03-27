# SListView
* custom tableView of horizontal sliding

# Function
* 水平滑动的自定义tableView
* 实现了复用机制
* 有待继续完善“循环滑动”、“垂直滑动”、“卡片样式”

# Add to the Podfile
```objc 
pod 'SListView','~>0.2.0'
```
# How to use SListView
```objc 
- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = @[randomColor,randomColor,randomColor,randomColor,randomColor,randomColor];
    [self.view addSubview:self.listView];
}

#pragma mark - SListViewDataSource
- (CGFloat)widthForColumnAtIndex:(NSInteger)index {
    return CGRectGetWidth(self.view.frame)/2.0;
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
- (void)listView:(SListView *)listView didSelectAtIndex:(NSInteger)index {
    NSLog(@"didSelectAtIndex :%ld",index);
}
- (void)listView:(SListView *)listView didScroll:(NSInteger)index {
    NSLog(@"didScroll :%ld",index);
}
#pragma mark - lazy init
- (SListView *)listView {
    if (!_listView) {
        _listView = [[SListView alloc] initWithFrame:CGRectMake(0, 200, CGRectGetWidth(self.view.frame), 200)];
        _listView.dataSource = self;
        _listView.delegate = self;
    }
    return _listView;
}
```

## Update
* V0.2.0 <br> 
  1.变宽<br>
  2.新增&修改方法<br>
  3.优化逻辑
* V0.1.1 <br> 
  1.修复reload bug,优化复用机制
* V0.1.0 <br> 
  1.首次上传
