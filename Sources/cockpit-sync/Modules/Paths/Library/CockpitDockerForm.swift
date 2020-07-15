protocol CockpitDockerForm: CockpitPathForm {
	
	/// A shell command string and a label-like description of its actions or scope.
	typealias DescribedCommand = (command: String, description: String)
	
	/// A pair of shell command arguments for a copy operation and a label-like description.
	typealias CopyArgumentPair = (source: String, destination: String, description: String)
	
}

extension CockpitDockerForm {
	
	// MARK: Command Form
	
	/// Returns a given command encapsulated to execute inside a one-off Docker container.
	/// Allows supplying arguments for mounting volumes to be used inside the container.
	func containerizedCommand(_ command: String, mounting volumeMountArguments: [String] = []) -> String {
		let insertableVolumeMountArguments = volumeMountArguments.joined(separator: " ")
		return "docker run --rm \(insertableVolumeMountArguments) alpine sh -c '\(command)\'"
	}
	
	// MARK: Argument Form
	
	/// Forms and returns respective mount arguments for the used Docker volume for Cockpit data
	/// and the archive directory used as source and destination for synchronization.
	func dockerMountArguments(volumeName: String, archivePath: Path) -> (volume: String, archive: String) {
		let volumeMountArgument = dockerVolumeMountArgument(volumeName: volumeName)
		let archiveMountArgument = dockerArchiveMountArgument(archivePath: archivePath)
		
		return (volumeMountArgument, archiveMountArgument)
	}

	func dockerVolumeMountArgument(volumeName: String) -> String {
		return "-v '\(volumeName):\(containerizedCockpitPath)'"
	}

	func dockerArchiveMountArgument(archivePath: Path) -> String {
		return "-v '\(archivePath):\(containerizedArchivePath):cached'"
	}
	
}
