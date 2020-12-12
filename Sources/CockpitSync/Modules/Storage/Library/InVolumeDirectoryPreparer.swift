/// Provider for directory operations, name, and path forming functionality for Cockpit storage in-volume.
protocol InVolumeDirectoryPreparer: AssertedShellCommandRunner, ContainerizedCommandProvider {}

extension InVolumeDirectoryPreparer {

	/// Checks if the cockpit root and its subdirectories exist in-volume.
	///
	/// Consumes all errors, returns `true` if directories can all be
	/// confirmed, `false` if either one or more can not be checked
	/// for file system stats or if the command to check stats has failed.
	func inVolumeDirectoriesExist(for scope: Scope, volumeName: String) -> Bool {
		let containerizedDirectoryNames = inVolumeDirectoryPaths(for: scope)
		let volumeMountArgument = dockerVolumeMountArgument(volumeName: volumeName)
		let command = containerizedCommand("stat \(containerizedDirectoryNames.joined(separator: " "))", mounting: [volumeMountArgument])

		guard let result = runInShell(command), !result.hasError else {
			print("Could not stat in-volume Cockpit directories for provided paths in scope '\(scope)'. Checked paths: \(containerizedDirectoryNames.joined(separator: ", ")).")
			return false
		}

		return true
	}

	/// Creates all directories in the target Docker volume for the given scope.
	///
	/// Uses `mkdir` command to create directories as needed and gracefully skip the operation
	/// if any destination directories already exist (returning 0 for such runs).
	func setUpInVolumeDirectories(for scope: Scope, volumeName: String) throws {
		let containerizedDirectoryNames = inVolumeDirectoryPaths(for: scope)
		let volumeMountArgument = dockerVolumeMountArgument(volumeName: volumeName)
		let containerizedDirectorySetUpCommand = "mkdir -p \(containerizedDirectoryNames.joined(separator: " "))"
		let command = containerizedCommand(containerizedDirectorySetUpCommand, mounting: [volumeMountArgument])

		try runInShellAndAssert(command)
	}

	// MARK: Path Form

	private func inVolumeDirectoryPaths(for scope: Scope) -> [Path] {
		return inVolumeDirectoryNames(for: scope).map { directoryName in
			return "'\(containerizedCockpitPath)/\(directoryName)'"
		}
	}

	private func inVolumeDirectoryNames(for scope: Scope) -> [String] {
		switch scope {
		case .structure:
			return ["cache", "collections", "singleton", "tmp"]
		case .records:
			return ["data", "thumbs", "uploads"]
		case .everything:
			return reduce(allCasesIn: inVolumeDirectoryNames, excluding: .everything)
		}
	}
	
}
