/// Functionality for restoring structure and data from a previously prepared archive to a Cockpit instance.
protocol CockpitRestoreOperation: ContainerizedCommandProvider, ShellAssertedExecutionForm {}

extension CockpitRestoreOperation {
	
	// MARK: Operations
	
	func restoreDataFromArchive(for scope: Scope, volumeName: String, archivePath: Path) throws {
		let (volumeMountArgument, archiveMountArgument) = dockerMountArguments(volumeName: volumeName, archivePath: archivePath)
		let copyArguments = copyArgumentComponents(for: scope)
		let copyCommands = containerizedCopyCommands(with: copyArguments).enumerated().map { (offset: $0, command: $1.command, description: $1.description) }

		for (offset, command, description) in copyCommands {
			print("Restoring \(scope.description) from archive, processing \(description), step \(offset + 1)/\(copyCommands.count).")

			do {
				let command = containerizedCommand(command, mounting: [volumeMountArgument, archiveMountArgument])
				try executeAndAssert(command)
			} catch {
				print("Could not save \(description), archived data is either missing, can not be read or volume is unusable.")
			}
		}
	}

	func setPermissionsInVolume(volumeName: String) throws {
		let volumeMountArgument = dockerVolumeMountArgument(volumeName: volumeName)
		let command = containerizedCommand("chown -R xfs:xfs \(containerizedCockpitPath)", mounting: [volumeMountArgument])
		try executeAndAssert(command)
	}
	
	// MARK: Command Argument Form
	
	private func containerizedCopyCommands(with arguments: [CopyArgumentPair]) -> [DescribedCommand] {
		let copyCommands = arguments.map { arguments -> DescribedCommand in
			let (sourceComponent, destinationComponent, description) = arguments
			let source = "\(containerizedArchivePath)/\(sourceComponent)"
			let destination = "\(containerizedCockpitPath)/\(destinationComponent)"
			let command = "cp -Rf \(source) \(destination)"
			
			return (command, description)
		}
		
		return copyCommands
	}
	
	private func copyArgumentComponents(for scope: Scope) -> [CopyArgumentPair] {
		switch scope {
		case .records:
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
