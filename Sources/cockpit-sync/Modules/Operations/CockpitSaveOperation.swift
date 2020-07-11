protocol CockpitSaveOperation: CockpitDockerForm, CockpitShellExecutionForm {}

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
		let containerizedCommands = dockerContainerizedCopyCommands(with: copyArguments)
		
		for (index, enumeration) in containerizedCommands.enumerated() {
			let (command, description) = enumeration
			print("Saving cockpit \(scope.rawValue) to archive, processing \(description), step \(index + 1)/\(containerizedCommands.count).")
			
			let streams = execute("docker run -i --rm \(volumeMountArgument) \(archiveMountArgument) alpine sh -c '\(command)'")
			assertShellResult(streams)
		}
	}

	// MARK: Command Argument Form

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
