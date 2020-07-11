protocol CockpitShellExecutionForm {}

extension CockpitShellExecutionForm {
	
	// MARK: Assertion
	
	func assertShellResult(_ result: ShellStandardStreams?) {
		guard let result = result else {
			assertionFailure("Command could not be executed.")
			return
		}
		
		if result.hasError {
			assertionFailure("Command exited with errors. \(result.errorStringDebugDescription)")
		}
	}
	
}
