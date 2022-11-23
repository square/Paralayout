Pod::Spec.new do |s|
  s.name     = 'Paralayout'
  s.version  = '1.0.0-rc.3'
  s.license  = 'Apache License, Version 2.0'
  s.summary  = 'Paralayout is a simple set of assistive UI layout utilities. Size and position your UI with pixel-perfect precision. Design will love you!'
  s.homepage = 'https://github.com/square/Paralayout'
  s.authors  = 'Square'
  s.source   = { :git => 'https://github.com/square/Paralayout.git', :tag => s.version }
  s.source_files = 'Paralayout/*.{swift}'
  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'ParalayoutTests/*{.swift}'
  end
end
