protocol CockpitDirectoryPreparation: CockpitPathForm, CockpitShellExecutionForm {}

extension CockpitDirectoryPreparation {
	
	func archiveDirectoriesExist(for scope: Scope) -> Bool {
		let currentPath = workingDirectoryPath!
		let archiveDirectoryPaths = directoryHierarchyPathComponents(for: scope).map { pathComponent in
			return "\(currentPath)/\(archiveDirectoryName)/\(pathComponent)"
		}
		
		print("Checking if archive directories exist for scope '\(scope)', paths: \(archiveDirectoryPaths.map { "'\($0)'" }.joined(separator: ", ")).")
		
		for path in archiveDirectoryPaths {
			guard let result = execute("stat \(path)"), result.hasError == false else {
				return false
			}
		}
		
		return true
	}
	
}
