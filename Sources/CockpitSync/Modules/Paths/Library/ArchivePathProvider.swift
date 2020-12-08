protocol ArchivePathProvider {
	
	// MARK: Paths
	
	var workingDirectoryPath: Path? { get }
	var containerizedCockpitPath: Path { get }
	var containerizedArchivePath: Path { get }
	
}

extension ArchivePathProvider {
	
	// MARK: Paths
	
	var containerizedCockpitPath: Path { "/var/cockpit" }
	
	var containerizedArchivePath: Path { "/var/archive" }
	
	// MARK: Path Form
	
	func archiveDirectoryPaths(for scope: Scope) -> [Path] {
		switch scope {
		case .records:
			return ["data/db", "data/uploads"]
		case .structure:
			return ["structure/collections", "structure/singleton", "structure/api"]
		case .everything:
			return reduce(allCasesIn: archiveDirectoryPaths, excluding: Scope.everything)
		}
	}
	
}
