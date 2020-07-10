import Foundation

protocol CockpitSaveOperation: ShellProcessForm {

	typealias Scope = CockpitBackup.Scope
	
	typealias Path = String
	typealias CopyArgumentPair = (source: String, destination: String)

}

extension CockpitSaveOperation {
	
	// MARK: Paths
	
	private var archiveDirectoryName: String { "archive" }
	
	private var workingDirectoryPath: Path? { execute("pwd")?.outputString }
	
	private var containerizedCockpitPath: Path { "/var/cockpit" }
	
	private var containerizedArchivePath: Path { "/var/archive" }

	// MARK: Operations

	func setUpDirectories(for scope: Scope) {
		let relativePaths = directoryPathComponents(for: scope).map { component in
			return "./\(archiveDirectoryName)/\(component)"
		}
		
		let result = execute("mkdir -p \(relativePaths.joined(separator: " "))")
		assertShellResult(result)
	}
	
	func dockerVolumeExists(_ dockerVolumeName: String) -> Bool {
		let unverifiedResult = execute("docker volume inspect \(dockerVolumeName)")
		
		guard let result = unverifiedResult, result.hasError == false else {
			return false
		}
		
		return true
	}

	func saveCockpitToArchive(for scope: Scope, dockerVolumeName: String) {
		let (volumeMountArgument, archiveMountArgument) = dockerMountArguments(volumeName: dockerVolumeName)
		let containerizedCommand = dockerContainerizedCopyCommand(for: scope, dockerVolumeName: dockerVolumeName)
		
		let streams = execute("docker run -i --rm \(volumeMountArgument) \(archiveMountArgument) alpine sh -c '\(containerizedCommand)'")
		assertShellResult(streams)
	}
	
	private func dockerMountArguments(volumeName dockerVolumeName: String) -> (volume: String, archive: String) {
		let currentPath = workingDirectoryPath!
		let volumeMountArgument = "-v '\(dockerVolumeName):\(containerizedCockpitPath)'"
		let archiveMountArgument = "-v '\(currentPath)/\(archiveDirectoryName):\(containerizedArchivePath)'"
		
		return (volumeMountArgument, archiveMountArgument)
	}
	
	private func dockerContainerizedCopyCommand(for scope: Scope, dockerVolumeName: String) -> String {
		let copyArguments = self.copyArgumentPairs(for: scope)
		let copyCommand = copyArguments.map { pair -> String in
			let (sourceComponent, destinationComponent) = pair
			let source = "\(containerizedCockpitPath)/\(sourceComponent)"
			let destination = "\(containerizedArchivePath)/\(destinationComponent)"
			
			return "cp -R \(source) \(destination)"
		}
		
		return copyCommand.joined(separator: "; ")
	}
	
	// MARK: Assertion
	
	private func assertShellResult(_ result: ShellStandardStreams?) {
		guard let result = result else {
			assertionFailure("Command could not be executed.")
			return
		}
		
		if result.hasError {
			assertionFailure("Command exited with errors. \(result.errorStringDebugDescription)")
		}
	}

	// MARK: Path Form

	private func directoryPathComponents(for scope: Scope) -> [Path] {
		switch scope {
			case .data:
				return ["data/db", "data/uploads"]
			case .structure:
				return ["structure/collections"]
			case .everything:
				return directoryPathComponents(for: .structure) + directoryPathComponents(for: .data)
		}
	}

	private func copyArgumentPairs(for scope: Scope) -> [CopyArgumentPair] {
		switch scope {
			case .data:
				return [
					("data/*", "data/db"),
					("uploads/*", "data/uploads")
				]
			case .structure:
				return [
					("collections/*", "structure/collections"),
					("api*", "structure/")
				]
			case .everything:
				return copyArgumentPairs(for: .structure) + copyArgumentPairs(for: .data)
		}
	}

}
