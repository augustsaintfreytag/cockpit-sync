protocol CockpitDockerForm: CockpitPathForm {
	
	typealias DescribedCommand = (command: String, description: String)
	typealias CopyArguments = (source: String, destination: String, description: String)
	
}

extension CockpitDockerForm {
	
	// MARK: Argument Form
	
	func dockerMountArguments(volumeName dockerVolumeName: String) -> (volume: String, archive: String) {
		let currentPath = workingDirectoryPath!
		let volumeMountArgument = "-v '\(dockerVolumeName):\(containerizedCockpitPath)'"
		let archiveMountArgument = "-v '\(currentPath)/\(archiveDirectoryName):\(containerizedArchivePath):cached'"
		
		return (volumeMountArgument, archiveMountArgument)
	}
	
}
