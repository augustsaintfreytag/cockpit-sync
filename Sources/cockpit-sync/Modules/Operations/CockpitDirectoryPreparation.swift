protocol CockpitDirectoryPreparation: ShellAssertedExecutionForm, ContainerizedCommandProvider {}

extension CockpitDirectoryPreparation {

	/// Checks if the archive and its subdirectories exist to run an operation in the given scope.
	func archiveDirectoriesExist(for scope: Scope, archivePath: Path) throws -> Bool {
		let paths = archiveDirectoryPaths(for: scope).map { pathComponent in
			return "'\(archivePath)/\(pathComponent)'"
		}

		guard let result = execute("stat \(paths.joined(separator: " "))"), !result.hasError else {
			throw ExecutionError(
				errorDescription: "Could not stat archive directories for provided paths in scope '\(scope)'. Checked paths: \(paths.joined(separator: ", "))."
			)
		}

		guard !result.hasError else {
			return false
		}

		return true
	}

	/// Checks if the cockpit root and its subdirectories exist in-volume.
	func cockpitDirectoriesExist(for scope: Scope, volumeName: String) throws -> Bool {
		let containerizedDirectoryNames = containerizedCockpitDirectoryNames(for: scope)
		let volumeMountArgument = dockerVolumeMountArgument(volumeName: volumeName)
		let command = containerizedCommand("stat \(containerizedDirectoryNames.joined(separator: " "))", mounting: [volumeMountArgument])

		guard let result = execute(command) else {
			throw ExecutionError(
				errorDescription: "Could not stat in-volume Cockpit directories for provided paths in scope '\(scope)'. Checked paths: \(containerizedDirectoryNames.joined(separator: ", "))."
			)
		}

		guard !result.hasError else {
			return false
		}

		return true
	}

	/// Creates all directories in the target Docker volume for the given scope.
	///
	/// Uses `mkdir` command to create directories as needed and gracefully skip the operation
	/// if any destination directories already exist (returning 0 for such runs).
	func setUpCockpitDirectories(for scope: Scope, volumeName: String) throws {
		let containerizedDirectoryNames = containerizedCockpitDirectoryNames(for: scope)
		let volumeMountArgument = dockerVolumeMountArgument(volumeName: volumeName)
		let containerizedDirectorySetUpCommand = "mkdir -p \(containerizedDirectoryNames.joined(separator: " "))"
		let command = containerizedCommand(containerizedDirectorySetUpCommand, mounting: [volumeMountArgument])

		try executeAndAssert(command)
	}

	// MARK: Command Argument Form

	private func containerizedCockpitDirectoryNames(for scope: Scope) -> [String] {
		return cockpitDirectoryNames(for: scope).map { directoryName in
			return "'\(containerizedCockpitPath)/\(directoryName)'"
		}
	}

	private func cockpitDirectoryNames(for scope: Scope) -> [String] {
		switch scope {
		case .structure:
			return ["cache", "collections", "singleton", "tmp"]
		case .records:
			return ["data", "thumbs", "uploads"]
		case .everything:
			return reduce(allCasesIn: cockpitDirectoryNames, excluding: .everything)
		}
	}
	
}
