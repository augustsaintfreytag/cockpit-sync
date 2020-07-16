protocol DockerVolumePreparationForm: ShellExecutionForm {}

extension DockerVolumePreparationForm {
	
	func dockerVolumeExists(_ dockerVolumeName: String) -> Bool {
		guard let result = execute("docker volume inspect \(dockerVolumeName)"), result.hasError == false else {
			return false
		}
		
		return true
	}
	
}
