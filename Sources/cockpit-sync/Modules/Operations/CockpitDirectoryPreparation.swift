protocol CockpitDirectoryPreparation: CockpitPathForm, ShellExecutionForm {}

extension CockpitDirectoryPreparation {
	
	func archiveDirectoriesExist(for scope: Scope, archivePath: Path) -> Bool {
		let archiveDirectoryPaths = directoryHierarchyPathComponents(for: scope).map { pathComponent in
			return "\(archivePath)/\(pathComponent)"
		}
		
		for path in archiveDirectoryPaths {
			guard let result = execute("stat '\(path)'"), result.hasError == false else {
				print("Path '\(path)' is missing.")
				return false
			}
		}
		
		return true
	}
	
}
