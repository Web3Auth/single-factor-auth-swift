Pod::Spec.new do |spec|
  spec.name         = "SingleFactorAuth"
  spec.version      = "0.0.1"
  spec.ios.deployment_target  = "13.0"
  spec.summary      = "Enable one key flow for Web3Auth"
  spec.homepage     = "https://github.com/Web3Auth/single-factor-auth-swift"
  spec.license      = { :type => 'BSD', :file => 'License.md' }
  spec.swift_version   = "5.0"
  spec.author       = { "Torus Labs" => "hello@tor.us" }
  spec.module_name = "SingleFactorAuth"
  spec.source       = { :git => "https://github.com/Web3Auth/single-factor-auth-swift/.git", :tag => spec.version }
  spec.source_files = "Sources/SingleFactorAuth/*.{swift,json}","Sources/SingleFactorAuth/**/*.{swift,json}"
  spec.dependency 'Torus-fetchNodeDetails', '~> 4.0.0'
  spec.dependency 'Torus-utils', '~> 4.0.0'
end
