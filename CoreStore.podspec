Pod::Spec.new do |s|
    s.name = "CoreStore"
    s.version = "2.0.0"
    s.license = "MIT"
    s.summary = "Unleashing the real power of Core Data with the elegance and safety of Swift"
    s.homepage = "https://github.com/JohnEstropia/CoreStore"
    s.author = { "John Rommel Estropia" => "rommel.estropia@gmail.com" }
    s.source = { :git => "https://github.com/JohnEstropia/CoreStore.git", :tag => s.version.to_s }

    s.ios.deployment_target = "8.0"
    s.osx.deployment_target = "10.10"
    s.watchos.deployment_target = "2.0"
    s.tvos.deployment_target = "9.0"

    s.source_files = "Sources", "Sources/**/*.{swift}"
    s.osx.exclude_files = "Sources/Observing/*.{swift}", "Sources/Internal/FetchedResultsControllerDelegate.swift", "Sources/Internal/CoreStoreFetchedResultsController.swift", "Sources/Convenience Helpers/NSFetchedResultsController+Convenience.swift"
    s.frameworks = "Foundation", "CoreData"
    s.requires_arc = true
    s.pod_target_xcconfig = { 'OTHER_SWIFT_FLAGS' => '-D USE_FRAMEWORKS' }
    
    s.dependency "GCDKit", "1.2.0"
end