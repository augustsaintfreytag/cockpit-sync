import Foundation
import ArgumentParser

struct CockpitBackup: ParsableCommand, ShellProcessForm {

}

// MARK: Library

extension CockpitBackup {

	enum Mode: String, ExpressibleByArgument {
		case save
		case restore
	}

	enum Scope: String, ExpressibleByArgument {
		case everything
		case structure
		case data
	}

}

// MARK: Entry

CockpitBackup.main()
