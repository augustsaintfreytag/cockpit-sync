protocol CockpitPathForm: PathForm, ShellExecutionForm {
	
	// MARK: Path Components
	
	var archiveDirectoryName: String { get }
	
	// MARK: Paths
	
	var workingDirectoryPath: Path? { get }
	var containerizedCockpitPath: Path { get }
	var containerizedArchivePath: Path { get }
	
}

extension CockpitPathForm {
	
	// MARK: Paths
	
	var archiveDirectoryName: String { "archive.nosync" }
	
	var workingDirectoryPath: Path? { execute("pwd")?.outputString }
	
	var containerizedCockpitPath: Path { "/var/cockpit" }
	
	var containerizedArchivePath: Path { "/var/archive" }
	
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
