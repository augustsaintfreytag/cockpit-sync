/// Functionality for saving maintained structure and data of a Cockpit instance to a destination archive.
protocol CockpitSaveOperation: ContainerizedCommandProvider, AssertedShellCommandRunner {}

extension CockpitSaveOperation {

	// MARK: Operations

	func setUpArchiveDirectories(for scope: Scope, in archivePath: Path) throws {
		let relativePaths = archiveDirectoryPaths(for: scope).map { component in
			return "'\(archivePath)/\(component)'"
		}
		
		try runInShellAndAssert("mkdir -p \(relativePaths.joined(separator: " "))")
	}
	
	func clearArchiveDirectories(for scope: Scope, in archivePath: Path) throws {
		let removalPaths = archiveDirectoryPaths(for: scope)
		let removalCommands = removalPaths.map { pathComponent in
			return "rm -rf '\(archivePath)/\(pathComponent)'"
		}
		
		let chainedRemovalCommands = removalCommands.joined(separator: "; ")
		try runInShellAndAssert(chainedRemovalCommands)
	}

	func saveCockpitToArchive(for scope: Scope, volumeName: String, archivePath: Path) throws {
		let (volumeMountArgument, archiveMountArgument) = dockerMountArguments(volumeName: volumeName, archivePath: archivePath)
		let copyArguments = copyArgumentComponents(for: scope)
		let copyCommands = containerizedCopyCommands(with: copyArguments).enumerated().map { (offset: $0, command: $1.command, description: $1.description) }
		
		for (offset, command, description) in copyCommands {
			print("Saving \(scope.description) to archive, processing \(description), step \(offset + 1)/\(copyCommands.count).")

			do {
				let command = containerizedCommand(command, mounting: [volumeMountArgument, archiveMountArgument])
				try runInShellAndAssert(command)
			} catch {
				print("Could not save \(description), input data is either missing, can not be read or archive directory is unusable.")
			}
		}
	}

	// MARK: Command Argument Form
	
	private func containerizedCopyCommands(with arguments: [CopyArgumentPair]) -> [DescribedCommand] {
		let copyCommands = arguments.map { arguments -> DescribedCommand in
			let (sourceComponent, destinationComponent, description) = arguments
			let source = "\(containerizedCockpitPath)/\(sourceComponent)"
			let destination = "\(containerizedArchivePath)/\(destinationComponent)"
			let command = "cp -Rf \(source) \(destination)"
			
			return (command, description)
		}
		
		return copyCommands
	}

	private func copyArgumentComponents(for scope: Scope) -> [CopyArgumentPair] {
		switch scope {
		case .records:
			return [
				("data/*", "data/db", "database"),
				("uploads/*", "data/uploads", "files and assets")
			]
		case .structure:
			return [
				("collections/*", "structure/collections", "collections"),
				("singleton/*", "structure/singleton", "singletons"),
				("api*", "structure/api", "API data and credentials")
			]
		case .everything:
			return reduce(allCasesIn: copyArgumentComponents, excluding: Scope.everything)
		}
	}

}
