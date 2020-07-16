import Foundation

/// Data of termination and standard streams of a child process executed through the system shell.
struct ShellResult {

	// MARK: Properties

	let status: Int32
	let outputData: Data
	let errorData: Data
	
	var hasOutput: Bool {
		outputString?.isEmpty == false
	}
	
	var hasError: Bool {
		errorString?.isEmpty == false
	}
	
	// MARK: Conversions
	
	var outputString: String? {
		Self.normalizedString(from: outputData)
	}
	
	var errorString: String? {
		Self.normalizedString(from: errorData)
	}
	
	// MARK: Init
	
	init(_ status: Int32, _ output: Data, _ error: Data) {
		self.status = status
		self.outputData = output
		self.errorData = error
	}
	
	init(_ status: Int32, _ outputStream: Pipe, _ errorStream: Pipe) {
		self.status = status
		self.outputData = Self.data(from: outputStream)
		self.errorData = Self.data(from: errorStream)
	}

	init(from process: Process) {
		self.status = process.terminationStatus
		self.outputData = Self.data(fromUncastProcessStream: process.standardOutput)
		self.errorData = Self.data(fromUncastProcessStream: process.standardError)
	}
	
}

// MARK: Utility

extension ShellResult {

	private static func data(fromUncastProcessStream uncastProcessStream: Any?) -> Data {
		guard let pipe = uncastProcessStream as? Pipe else {
			return Data()
		}

		return Self.data(from: pipe)
	}

	private static func data(from outputStream: Pipe) -> Data {
		return outputStream.fileHandleForReading.readDataToEndOfFile()
	}
	
	private static func normalizedString(from data: Data) -> String? {
		guard let rawString = String(data: data, encoding: .utf8) else {
			return nil
		}
		
		return rawString.trimmingCharacters(in: .whitespacesAndNewlines)
	}
	
}

// MARK: Debug String Form

extension ShellResult: CustomDebugStringConvertible {
	
	var debugDescription: String {
		guard errorData.isEmpty else {
			return "Standard Error: \(errorStringDebugDescription)"
		}
		
		return "Standard Output: \(outputStringDebugDescription)"
	}
	
	var outputStringDebugDescription: String {
		stringDebugDescription(forPropertyAt: \.outputString)
	}
	
	var errorStringDebugDescription: String {
		stringDebugDescription(forPropertyAt: \.errorString)
	}
	
	private func stringDebugDescription(forPropertyAt keyPath: KeyPath<ShellResult, String?>) -> String {
		guard let string = self[keyPath: keyPath] else {
			return "<Unreadable, \(errorData.count) bytes>"
		}
		
		return string.replacingOccurrences(of: "\n", with: " […] ")
	}
	
}
