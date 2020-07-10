import Foundation

protocol CockpitPathForm {
	
	/// A path or path component describing a resource on the local system.
	typealias Path = String
	
}

extension CockpitPathForm {
	
	// MARK: Path Form
	
	func directoryPathComponents(for scope: Scope) -> [Path] {
		switch scope {
		case .data:
			return ["data"]
		case .structure:
			return ["structure"]
		case .everything:
			return reduce(allCasesIn: directoryPathComponents, excluding: Scope.everything)
		}
	}
	
	func directoryHierarchyPathComponents(for scope: Scope) -> [Path] {
		switch scope {
		case .data:
			return ["data/db", "data/uploads"]
		case .structure:
			return ["structure/collections"]
		case .everything:
			return reduce(allCasesIn: directoryHierarchyPathComponents, excluding: Scope.everything)
		}
	}
	
}
