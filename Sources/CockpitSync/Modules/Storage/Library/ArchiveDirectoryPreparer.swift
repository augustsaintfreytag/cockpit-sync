/// Provider for directory operations, name, and path forming functionality for archive storage.
protocol ArchiveDirectoryPreparer: AssertedShellCommandRunner, ContainerizedCommandProvider {}

extension ArchiveDirectoryPreparer {

	/// Checks if the archive and its subdirectories exist to run an operation in the given scope.
	func archiveDirectoriesExist(for scope: Scope, archivePath: Path) throws -> Bool {
		let paths = archiveDirectoryPaths(for: scope).map { pathComponent in
			return "'\(archivePath)/\(pathComponent)'"
		}

		guard let result = runInShell("stat \(paths.joined(separator: " "))") else {
			throw ExecutionError(
				errorDescription: "Could not stat archive directories for provided paths in scope '\(scope)'. Checked paths: \(paths.joined(separator: ", "))."
			)
		}

		guard !result.hasError else {
			return false
		}

		return true
	}

	/// Create directories required in an archive destination needed to save data of the provided scope.
	func setUpArchiveDirectories(for scope: Scope, in archivePath: Path) throws {
		let relativePaths = archiveDirectoryPaths(for: scope).map { component in
			return "'\(archivePath)/\(component)'"
		}

		try runInShellAndAssert("mkdir -p \(relativePaths.joined(separator: " "))")
	}

	/// Clear contents of an archive destination to allow saving new data of the provided scope.
	func clearArchiveDirectories(for scope: Scope, in archivePath: Path) throws {
		let removalPaths = archiveDirectoryPaths(for: scope)
		let removalCommands = removalPaths.map { pathComponent in
			return "rm -rf '\(archivePath)/\(pathComponent)'"
		}

		let chainedRemovalCommands = removalCommands.joined(separator: "; ")
		try runInShellAndAssert(chainedRemovalCommands)
	}

}
