
Pod::Spec.new do |s|
  s.name             = 'SListView'
  s.version          = '0.1.0'
  s.summary          = 'custom tableView of horizontal sliding'
  s.description      = <<-DESC
                        可以水平滑动的tableView
                       DESC
  s.homepage         = 'https://github.com/x5forever/SListView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'x5' => '644035652@qq.com' }
  s.source           = { :git => 'https://github.com/x5forever/SListView.git', :tag => 'V'+s.version.to_s }

  s.platform     = :ios, "7.0"
  s.source_files = "SListViewDemo/SListViewDemo/Classes/*.{h,m}"
  s.frameworks = 'UIKit'
  s.requires_arc = true
end