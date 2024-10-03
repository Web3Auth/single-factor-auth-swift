Pod::Spec.new do |spec|
  spec.name         = "SingleFactorAuth"
  spec.version      = "9.0.0"
  spec.ios.deployment_target  = "14.0"
  spec.summary      = "Enable one key flow for Web3Auth"
  spec.homepage     = "https://github.com/Web3Auth/single-factor-auth-swift"
  spec.license      = { :type => 'BSD', :file => 'License.md' }
  spec.swift_version   = "5.0"
  spec.author       = { "Torus Labs" => "hello@tor.us" }
  spec.module_name = "SingleFactorAuth"
  spec.source       = { :git => "https://github.com/web3Auth/single-factor-auth-swift", :tag => spec.version }
  spec.source_files = "Sources/SingleFactorAuth/*.{swift,json}","Sources/SingleFactorAuth/**/*.{swift,json}"
  spec.dependency 'curvelib.swift', '~> 1.0.1'
  spec.dependency 'Torus-utils', '~> 10.0.0'
  spec.dependency 'TorusSessionManager', '~> 5.0.0'
end
