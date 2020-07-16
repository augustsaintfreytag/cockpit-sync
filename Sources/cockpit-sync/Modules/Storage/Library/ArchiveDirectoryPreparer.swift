/// Provider for directory operations, name, and path forming functionality for archive storage.
protocol ArchiveDirectoryPreparer: AssertedShellCommandRunner, ContainerizedCommandProvider {}

extension ArchiveDirectoryPreparer {

	/// Checks if the archive and its subdirectories exist to run an operation in the given scope.
	func archiveDirectoriesExist(for scope: Scope, archivePath: Path) throws -> Bool {
		let paths = archiveDirectoryPaths(for: scope).map { pathComponent in
			return "'\(archivePath)/\(pathComponent)'"
		}

		guard let result = runInShell("stat \(paths.joined(separator: " "))"), !result.hasError else {
			throw ExecutionError(
				errorDescription: "Could not stat archive directories for provided paths in scope '\(scope)'. Checked paths: \(paths.joined(separator: ", "))."
			)
		}

		guard !result.hasError else {
			return false
		}

		return true
	}

}
