protocol ContainerizedCommandProvider: ArchivePathProvider {
	
	/// A shell command string and a label-like description of its actions or scope.
	typealias DescribedCommand = (command: String, description: String)
	
	/// A pair of shell command arguments for a copy operation and a label-like description.
	typealias CopyArgumentPair = (source: String, destination: String, description: String)
	
}

extension ContainerizedCommandProvider {
	
	// MARK: Command Form
	
	/// Returns a given command encapsulated to execute inside a one-off Docker container.
	/// Allows supplying arguments for mounting volumes to be used inside the container.
	func containerizedCommand(_ command: String, mounting volumeMountArguments: [String] = []) -> String {
		let insertableVolumeMountArguments = volumeMountArguments.joined(separator: " ")
		return "docker run --rm \(insertableVolumeMountArguments) alpine sh -c '\(command)\'"
	}
	
	// MARK: Mount Argument Form
	
	/// Forms and returns respective mount arguments for a Docker volume for Cockpit data and an archive directory.
	func dockerMountArguments(volumeName: String, archivePath: Path) -> (volume: String, archive: String) {
		let volumeMountArgument = dockerVolumeMountArgument(volumeName: volumeName)
		let archiveMountArgument = dockerArchiveMountArgument(archivePath: archivePath)
		
		return (volumeMountArgument, archiveMountArgument)
	}

	/// Returns an argument used to mount a Docker volume for Cockpit data to a container.
	func dockerVolumeMountArgument(volumeName: String) -> String {
		return "-v '\(volumeName):\(containerizedCockpitPath)'"
	}

	/// Returns an argument used to mount an archive directory present at the given path to a container.
	func dockerArchiveMountArgument(archivePath: Path) -> String {
		return "-v '\(archivePath):\(containerizedArchivePath):delegated'"
	}
	
}
