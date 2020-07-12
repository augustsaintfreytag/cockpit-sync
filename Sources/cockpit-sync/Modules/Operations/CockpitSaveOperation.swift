protocol CockpitSaveOperation: CockpitDockerForm, ShellExecutionForm, ShellAssertedExecutionForm {}

extension CockpitSaveOperation {

	// MARK: Operations

	func setUpArchiveDirectories(for scope: Scope, in archivePath: Path) {
		let relativePaths = directoryHierarchyPathComponents(for: scope).map { component in
			return "'\(archivePath)/\(component)'"
		}
		
		let result = execute("mkdir -p \(relativePaths.joined(separator: " "))")
		assertShellResult(result)
	}
	
	func clearArchiveDirectories(for scope: Scope, in archivePath: Path) {
		let removalPathComponents = directoryPathComponents(for: scope)
		let removalCommands = removalPathComponents.map { pathComponent in
			return "rm -rf '\(archivePath)/\(pathComponent)'"
		}
		
		let removalCommand = removalCommands.joined(separator: "; ")
		let shellResult = execute(removalCommand)
		assertShellResult(shellResult)
	}

	func saveCockpitToArchive(for scope: Scope, volumeName: String, archivePath: Path) {
		let (volumeMountArgument, archiveMountArgument) = dockerMountArguments(volumeName: volumeName, archivePath: archivePath)
		let copyArguments = copyArgumentComponents(for: scope)
		let copyCommands = containerizedCopyCommands(with: copyArguments).enumerated().map { (offset: $0, command: $1.command, description: $1.description) }
		
		for (offset, command, description) in copyCommands {
			print("Saving \(scope.rawValue) to archive, processing \(description), step \(offset + 1)/\(copyCommands.count).")
			
			let streams = execute("docker run --rm \(volumeMountArgument) \(archiveMountArgument) alpine sh -c \"\(command)\"")
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
				("singleton/*", "structure/singleton", "singletons"),
				("api*", "structure/", "API data and credentials")
			]
		case .everything:
			return reduce(allCasesIn: copyArgumentComponents, excluding: Scope.everything)
		}
	}

}
