import Foundation

/// Data of standard streams of a child process executed through the system shell.
struct ShellStandardStreams {
	
	// MARK: Properties
	
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
	
	init(_ output: Data, _ error: Data) {
		self.outputData = output
		self.errorData = error
	}
	
	init(_ outputStream: Pipe, _ errorStream: Pipe) {
		self.outputData = Self.data(from: outputStream)
		self.errorData = Self.data(from: errorStream)
	}
	
}

// MARK: Utility

extension ShellStandardStreams {
	
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

extension ShellStandardStreams: CustomDebugStringConvertible {
	
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
	
	private func stringDebugDescription(forPropertyAt keyPath: KeyPath<ShellStandardStreams, String?>) -> String {
		guard let string = self[keyPath: keyPath] else {
			return "<Unreadable, \(errorData.count) bytes>"
		}
		
		return string.replacingOccurrences(of: "\n", with: " […] ")
	}
	
}
