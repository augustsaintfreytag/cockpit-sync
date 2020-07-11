protocol CockpitRestoreOperation: CockpitDockerForm, ShellExecutionForm, ShellAssertionForm {}

extension CockpitRestoreOperation {
	
	// MARK: Operations
	
	func restoreCockpitFromArchive(for scope: Scope, volumeName: String, archivePath: Path) {
		let (volumeMountArgument, archiveMountArgument) = dockerMountArguments(volumeName: volumeName, archivePath: archivePath)
		
		// Directories
		do {
			let containerizedDirectoryNames = cockpitDirectoryNames.map { directoryName in
				return "\(containerizedCockpitPath)/\(directoryName)"
			}
			
			let containerizedDirectorySetUpCommand = "mkdir -p \(containerizedDirectoryNames.joined(separator: " "))"
			let command = containerizedCommand(containerizedDirectorySetUpCommand, mounting: [volumeMountArgument])
			let streams = execute(command)
			assertShellResult(streams)
		}
		
		// Data Copy
		do {
			let copyArguments = copyArgumentComponents(for: scope)
			let copyCommands = containerizedCopyCommands(with: copyArguments).enumerated().map { (offset: $0, command: $1.command, description: $1.description) }
			
			for (offset, command, description) in copyCommands {
				print("Restoring \(scope.rawValue) from archive, processing \(description), step \(offset + 1)/\(copyCommands.count).")
				
				let command = containerizedCommand(command, mounting: [volumeMountArgument, archiveMountArgument])
				let streams = execute(command)
				assertShellResult(streams)
			}
		}
		
		// Permissions
		do {
			let command = containerizedCommand("chown -R xfs:xfs \(containerizedCockpitPath)", mounting: [volumeMountArgument])
			let streams = execute(command)
			assertShellResult(streams)
		}
	}
	
	// MARK: Command Form
	
	private func containerizedCommand(_ command: String, mounting volumeMountArguments: [String]) -> String {
		let insertableVolumeMountArguments = volumeMountArguments.joined(separator: " ")
		return "docker run --rm \(insertableVolumeMountArguments) alpine sh -c '\(command)\'"
	}
	
	// MARK: Command Argument Form
	
	private var cockpitDirectoryNames: [String] {
		["cache", "collections", "data", "singleton", "thumbs", "tmp", "uploads"]
	}
	
	private func containerizedCopyCommands(with arguments: [CopyArguments]) -> [DescribedCommand] {
		let copyCommands = arguments.map { arguments -> DescribedCommand in
			let (sourceComponent, destinationComponent, description) = arguments
			let source = "\(containerizedArchivePath)/\(sourceComponent)"
			let destination = "\(containerizedCockpitPath)/\(destinationComponent)"
			let command = "cp -Rf \(source) \(destination)"
			
			return (command, description)
		}
		
		return copyCommands
	}
	
	private func copyArgumentComponents(for scope: Scope) -> [CopyArguments] {
		switch scope {
		case .data:
			return [
				("data/db/*", "data/", "database"),
				("data/uploads/*", "uploads/", "files and assets")
			]
		case .structure:
			return [
				("structure/collections/*", "collections/", "collections"),
				("structure/singleton/*", "singleton/", "singletons"),
				("structure/api*", "", "API data and credentials")
			]
		case .everything:
			return reduce(allCasesIn: copyArgumentComponents, excluding: Scope.everything)
		}
	}
	
}
