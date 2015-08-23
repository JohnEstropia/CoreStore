Pod::Spec.new do |s|
    s.name = "CoreStore"
    s.version = "1.2.1"
    s.license = "MIT"
    s.summary = "Simple, elegant, and smart Core Data programming with Swift"
    s.homepage = "https://github.com/JohnEstropia/CoreStore"
    s.author = { "John Rommel Estropia" => "rommel.estropia@gmail.com" }
    s.source = { :git => "https://github.com/JohnEstropia/CoreStore.git", :tag => s.version.to_s }

    s.ios.deployment_target = "8.0"

    s.source_files = "CoreStore", "CoreStore/**/*.{swift}"
    s.frameworks = "Foundation", "UIKit", "CoreData"
    s.requires_arc = true
    s.dependency "GCDKit", "1.1.1"
end