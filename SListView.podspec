
Pod::Spec.new do |s|
  s.name             = 'SListView'
  s.version          = '0.2.0'
  s.summary          = 'custom tableView of horizontal sliding'
  s.description      = <<-DESC
                        可以水平滑动的自定义tableView,后续有待继续优化支持“循环滑动”,“垂直滑动”以及“卡片样式”，
                       DESC
  s.homepage         = 'https://github.com/x5forever/SListView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'x5' => 'x5forever@163.com' }
  s.source           = { :git => 'https://github.com/x5forever/SListView.git', :tag => 'V'+s.version.to_s }

  s.platform     = :ios, "7.0"
  s.source_files = "SListViewDemo/SListViewDemo/Classes/*.{h,m}"
  s.frameworks = 'UIKit'
  s.requires_arc = true
end
