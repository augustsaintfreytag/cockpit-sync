protocol CockpitSaveOperation: CockpitDockerForm, ShellExecutionForm, ShellAssertionForm {}

extension CockpitSaveOperation {

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

	func saveCockpitToArchive(for scope: Scope, dockerVolumeName: String) {
		let (volumeMountArgument, archiveMountArgument) = dockerMountArguments(volumeName: dockerVolumeName)
		let copyArguments = copyArgumentComponents(for: scope)
		let copyCommands = containerizedCopyCommands(with: copyArguments).enumerated().map { (offset: $0, command: $1.command, description: $1.description) }
		
		for (offset, command, description) in copyCommands {
			print("Saving \(scope.rawValue) to archive, processing \(description), step \(offset + 1)/\(copyCommands.count).")
			
			let streams = execute("docker run --rm \(volumeMountArgument) \(archiveMountArgument) alpine sh -c '\(command)'")
			assertShellResult(streams)
		}
	}

	// MARK: Command Argument Form
	
	private func containerizedCopyCommands(with arguments: [CopyArguments]) -> [DescribedCommand] {
		let copyCommands = arguments.map { arguments -> DescribedCommand in
			let (sourceComponent, destinationComponent, description) = arguments
			let source = "\(containerizedCockpitPath)/\(sourceComponent)"
			let destination = "\(containerizedArchivePath)/\(destinationComponent)"
			let command = "cp -Rf \(source) \(destination)"
			
			return (command, description)
		}
		
		return copyCommands
	}

	private func copyArgumentComponents(for scope: Scope) -> [CopyArguments] {
		switch scope {
		case .data:
			return [
				("data/*", "data/db", "database"),
				("uploads/*", "data/uploads", "files and assets")
			]
		case .structure:
			return [
				("collections/*", "structure/collections", "collections"),
				("api*", "structure/", "API data and credentials")
			]
		case .everything:
			return reduce(allCasesIn: copyArgumentComponents, excluding: Scope.everything)
		}
	}

}
