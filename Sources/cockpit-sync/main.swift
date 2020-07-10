import Foundation
import ArgumentParser

struct CockpitBackup: ParsableCommand, CockpitSaveForm, ShellProcessForm {

	static var configuration = CommandConfiguration(
		abstract: "Saves or restores data of a Cockpit CMS instance.",
		discussion: lines(
			"Handles saving and restoring of internal data stores of Cockpit CMS (getcockpit.com),",
			"an open source content management system, developed and maintained by Agentejo.",
			"Additionally offers reading or writing data to and from a destination Git repository,",
			"allowing synchronization of extracted data with a remote repository."
		)
	)

	// MARK: Arguments & Options

	@Argument(help: "The mode of the operation.")
	var mode: Mode

	@Option(name: [.long, .short], help: "The scope of the operation.")
	var scope: Scope = .everything
	
	@Option(name: [.customLong("docker-volume"), .customShort("v")], help: "The name of the Docker volume used by Cockpit CMS to store data.")
	var dockerVolumeName: String

	@Option(name: [.customLong("path"), .customShort("p")], help: "The archive directory used to read and write data.")
	var archivePath: String = "./archive"

	// MARK: Run

	func run() throws {
		print("Running with mode '\(mode.rawValue)', scope '\(scope.rawValue)', supplied volume '\(dockerVolumeName)'.")

		switch mode {
		case .save:
			runSave()
		case .restore:
			runRestore()
		}
	}
	
	private func runSave() {
		guard dockerVolumeExists(dockerVolumeName) else {
			assertionFailure("Docker volume named '\(dockerVolumeName)' does not exist.")
			return
		}
		
		setUpDirectories(for: scope)
		saveCockpitToArchive(for: scope, dockerVolumeName: dockerVolumeName)
	}
	
	private func runRestore() {
		// TODO: Implement restore capabilities.
		fatalError("Not implemented.")
	}
	
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
