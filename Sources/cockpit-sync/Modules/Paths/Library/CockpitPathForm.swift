protocol CockpitPathForm {
	
	// MARK: Paths
	
	var workingDirectoryPath: Path? { get }
	var containerizedCockpitPath: Path { get }
	var containerizedArchivePath: Path { get }
	
}

extension CockpitPathForm {
	
	// MARK: Paths
	
	var containerizedCockpitPath: Path { "/var/cockpit" }
	
	var containerizedArchivePath: Path { "/var/archive" }
	
	// MARK: Path Form
	
	func directoryPathComponents(for scope: Scope) -> [Path] {
		switch scope {
		case .records:
			return ["data"]
		case .structure:
			return ["structure"]
		case .everything:
			return reduce(allCasesIn: directoryPathComponents, excluding: Scope.everything)
		}
	}
	
	func directoryHierarchyPathComponents(for scope: Scope) -> [Path] {
		switch scope {
		case .records:
			return ["data/db", "data/uploads"]
		case .structure:
			return ["structure/collections", "structure/singleton"]
		case .everything:
			return reduce(allCasesIn: directoryHierarchyPathComponents, excluding: Scope.everything)
		}
	}
	
}
