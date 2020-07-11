protocol CockpitDockerPreparation: ShellExecutionForm {}

extension CockpitDockerPreparation {
	
	func dockerVolumeExists(_ dockerVolumeName: String) -> Bool {
		let unverifiedResult = execute("docker volume inspect \(dockerVolumeName)")
		
		guard let result = unverifiedResult, result.hasError == false else {
			return false
		}
		
		return true
	}
	
}
