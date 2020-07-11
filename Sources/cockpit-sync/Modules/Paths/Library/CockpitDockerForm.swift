protocol CockpitDockerForm: CockpitPathForm {
	
	typealias DescribedCommand = (command: String, description: String)
	typealias CopyArguments = (source: String, destination: String, description: String)
	
}

extension CockpitDockerForm {
	
	// MARK: Argument Form
	
	func dockerMountArguments(volumeName: String, archivePath: Path) -> (volume: String, archive: String) {
		let volumeMountArgument = "-v '\(volumeName):\(containerizedCockpitPath)'"
		let archiveMountArgument = "-v '\(archivePath):\(containerizedArchivePath):cached'"
		
		return (volumeMountArgument, archiveMountArgument)
	}
	
}
