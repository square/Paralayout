Pod::Spec.new do |s|
  s.name     = 'Paralayout'
  s.version  = '2.0.0'
  s.license  = 'Apache License, Version 2.0'
  s.summary  = 'Paralayout is a simple set of assistive UI layout utilities. Size and position your UI with pixel-perfect precision. Design will love you!'
  s.homepage = 'https://github.com/square/Paralayout'
  s.authors  = 'Square'
  s.source   = { :git => 'https://github.com/square/Paralayout.git', :tag => s.version }
  s.swift_version = '6.0'
  s.source_files = 'Paralayout/*.{swift}'
  s.ios.deployment_target = '13.0'
end
