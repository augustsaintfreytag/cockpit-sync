protocol VolumePreparer: ShellCommandRunner {}

extension VolumePreparer {
	
	func dockerVolumeExists(_ dockerVolumeName: String) -> Bool {
		guard let result = runInShell("docker volume inspect \(dockerVolumeName)"), result.hasError == false else {
			return false
		}
		
		return true
	}
	
}
