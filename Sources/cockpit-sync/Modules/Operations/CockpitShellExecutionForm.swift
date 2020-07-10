//
//  CockpitShellForm.swift
//  cockpit-sync
//
//  Created by August Saint Freytag on 10/07/2020.
//

import Foundation

protocol CockpitShellExecutionForm: ShellExecutionForm {}

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
