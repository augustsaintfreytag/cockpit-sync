import Foundation

protocol ShellExecutionForm {}

extension ShellExecutionForm {
	
	// MARK: Process Form

	@discardableResult func execute(_ command: String) -> ShellResult? {
		let process = Process()

		process.executableURL = URL(fileURLWithPath: "/bin/bash")
		process.arguments = ["-c", command]

		let standardOutput = Pipe()
		process.standardOutput = standardOutput

		let standardError = Pipe()
		process.standardError = standardError

		do {
			try process.run()
		} catch {
			assertionFailure("Could not execute wrapped command '\(command)'. \(error.localizedDescription)")
			return nil
		}

		return ShellResult(from: process)
	}
	
}
