protocol CockpitDockerForm: CockpitPathForm {
	
	typealias DescribedCommand = (command: String, description: String)
	typealias CopyArguments = (source: String, destination: String, description: String)
	
}

extension CockpitDockerForm {
	
	// MARK: Argument Form
	
	func dockerMountArguments(volumeName dockerVolumeName: String) -> (volume: String, archive: String) {
		let currentPath = workingDirectoryPath!
		let volumeMountArgument = "-v '\(dockerVolumeName):\(containerizedCockpitPath):cached'"
		let archiveMountArgument = "-v '\(currentPath)/\(archiveDirectoryName):\(containerizedArchivePath):cached'"
		
		return (volumeMountArgument, archiveMountArgument)
	}
	
	// MARK: Command Form
	
	func dockerContainerizedCopyCommands(with arguments: [CopyArguments]) -> [DescribedCommand] {
		let copyCommands = arguments.map { arguments -> DescribedCommand in
			let (sourceComponent, destinationComponent, description) = arguments
			let source = "\(containerizedCockpitPath)/\(sourceComponent)"
			let destination = "\(containerizedArchivePath)/\(destinationComponent)"
			let command = "cp -R \(source) \(destination)"
			
			return (command, description)
		}
		
		return copyCommands
	}
	
}
