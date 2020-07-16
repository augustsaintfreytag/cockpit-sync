protocol AssertedShellCommandRunner: ShellCommandRunner {}

extension AssertedShellCommandRunner {
	
	// MARK: Assertion
	
	@discardableResult func runInShellAndAssert(_ command: String) throws -> ShellResult {
		guard let result = runInShell(command) else {
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
