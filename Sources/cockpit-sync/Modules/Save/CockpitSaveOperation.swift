import Foundation

protocol CockpitSaveOperation: ShellProcessForm {

	typealias Scope = CockpitBackup.Scope
	
	typealias Path = String
	typealias DescribedCommand = (command: String, description: String)
	typealias CopyArguments = (source: String, destination: String, description: String)

}

extension CockpitSaveOperation {
	
	// MARK: Paths
	
	private var archiveDirectoryName: String { "archive" }
	
	private var workingDirectoryPath: Path? { execute("pwd")?.outputString }
	
	private var containerizedCockpitPath: Path { "/var/cockpit" }
	
	private var containerizedArchivePath: Path { "/var/archive" }

	// MARK: Operations

	func setUpArchiveDirectories(for scope: Scope) {
		let relativePaths = directoryHierarchyPathComponents(for: scope).map { component in
			return "./\(archiveDirectoryName)/\(component)"
		}
		
		let result = execute("mkdir -p \(relativePaths.joined(separator: " "))")
		assertShellResult(result)
	}
	
	func clearArchiveDirectories(for scope: Scope) {
		let removalPathComponents = directoryPathComponents(for: scope)
		let removalCommands = removalPathComponents.map { pathComponent in
			return "rm -rf ./\(archiveDirectoryName)/\(pathComponent)"
		}
		
		let removalCommand = removalCommands.joined(separator: " && ")
		let shellResult = execute(removalCommand)
		assertShellResult(shellResult)
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
		let containerizedCommands = dockerContainerizedCopyCommands(for: scope, dockerVolumeName: dockerVolumeName)
		
		for (index, enumeration) in containerizedCommands.enumerated() {
			let (command, description) = enumeration
			print("Saving cockpit \(scope.rawValue) to archive, processing \(description), step \(index + 1)/\(containerizedCommands.count).")
			
			let streams = execute("docker run -i --rm \(volumeMountArgument) \(archiveMountArgument) alpine sh -c '\(command)'")
			assertShellResult(streams)
		}
	}
	
	private func dockerMountArguments(volumeName dockerVolumeName: String) -> (volume: String, archive: String) {
		let currentPath = workingDirectoryPath!
		let volumeMountArgument = "-v '\(dockerVolumeName):\(containerizedCockpitPath):cached'"
		let archiveMountArgument = "-v '\(currentPath)/\(archiveDirectoryName):\(containerizedArchivePath):cached'"
		
		return (volumeMountArgument, archiveMountArgument)
	}
	
	private func dockerContainerizedCopyCommands(for scope: Scope, dockerVolumeName: String) -> [DescribedCommand] {
		let copyArguments = copyArgumentComponents(for: scope)
		let copyCommands = copyArguments.map { arguments -> DescribedCommand in
			let (sourceComponent, destinationComponent, description) = arguments
			let source = "\(containerizedCockpitPath)/\(sourceComponent)"
			let destination = "\(containerizedArchivePath)/\(destinationComponent)"
			let command = "cp -R \(source) \(destination)"
			
			return (command, description)
		}
		
		return copyCommands
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
			return ["data"]
		case .structure:
			return ["structure"]
		case .everything:
			return reduce(allCasesIn: directoryPathComponents, excluding: Scope.everything)
		}
	}
	
	private func directoryHierarchyPathComponents(for scope: Scope) -> [Path] {
		switch scope {
		case .data:
			return ["data/db", "data/uploads"]
		case .structure:
			return ["structure/collections"]
		case .everything:
			return reduce(allCasesIn: directoryHierarchyPathComponents, excluding: Scope.everything)
		}
	}

	private func copyArgumentComponents(for scope: Scope) -> [CopyArguments] {
		switch scope {
		case .data:
			return [
				("data/*", "data/db", "Database"),
				("uploads/*", "data/uploads", "Files & Assets")
			]
		case .structure:
			return [
				("collections/*", "structure/collections", "Collections"),
				("api*", "structure/", "API Data & Credentials")
			]
		case .everything:
			return reduce(allCasesIn: copyArgumentComponents, excluding: Scope.everything)
		}
	}

}
