import Foundation

protocol CanonicalPathProvider {}

extension CanonicalPathProvider {
	
	func resolvedCanonicalPath(from path: Path) -> Path? {
		let resolvableURL = URL(fileURLWithPath: path)
		let resolvableURLResourceValues = try? resolvableURL.resourceValues(forKeys: [.canonicalPathKey])
		let canonicalPath = resolvableURLResourceValues?.canonicalPath
		
		return canonicalPath
	}
	
}
