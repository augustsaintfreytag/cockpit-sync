protocol ShellAssertedExecutionForm: ShellExecutionForm {}

extension ShellAssertedExecutionForm {
	
	// MARK: Assertion
	
	@discardableResult func executeAndAssert(_ command: String) throws -> ShellResult {
		guard let result = execute(command) else {
			throw ExecutionError(errorDescription: "Command could not be executed.")
		}
		
		if result.hasError {
			throw ExecutionError(errorDescription: "Command exited with errors. \(result.errorStringDebugDescription)")
		}
		
		return result
	}
	
	@available(*, deprecated, message: "Separate execute and assert is no longer supported, use `executeAndAssert(_:)` as a combined operation instead.")
	@discardableResult func assertShellResult(_ result: ShellResult?) throws -> ShellResult {
		guard let result = result else {
			throw ExecutionError(errorDescription: "Command could not be executed.")
		}
		
		if result.hasError {
			throw ExecutionError(errorDescription: "Command exited with errors. \(result.errorStringDebugDescription)")
		}
		
		return result
	}
	
	// MARK: Description Form
	
	private var debugDescriptionCharacterCutoff: Int { 36 }
	
	private func debugDescription(for command: String) -> String {
		guard command.count > debugDescriptionCharacterCutoff else {
			return command
		}
		
		return "\(command.prefix(debugDescriptionCharacterCutoff))…"
	}
	
}
