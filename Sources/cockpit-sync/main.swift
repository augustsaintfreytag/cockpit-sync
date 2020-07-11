import Foundation
import ArgumentParser

struct CockpitBackup: ParsableCommand, CockpitDirectoryPreparation, CockpitDockerPreparation, CockpitSaveOperation, CockpitRestoreOperation {
	
	// MARK: Configuration
	
	static var configuration = CommandConfiguration(
		abstract: "Saves or restores data of a Cockpit CMS instance.",
		discussion: lines(
			"Handles saving and restoring of internal data stores of Cockpit CMS (getcockpit.com),",
			"an open source content management system, developed and maintained by Agentejo.",
			"Additionally offers reading or writing data to and from a destination Git repository,",
			"allowing synchronization of extracted data with a remote repository."
		)
	)
	
	// MARK: Properties
	
	var workingDirectoryPath: Path? { execute("pwd")?.outputString }

	// MARK: Arguments & Options

	@Argument(help: "The mode of the operation. (options: save|restore)")
	var mode: Mode

	@Option(name: [.long, .short], help: "The scope of the operation. (options: structure|data|everything)")
	var scope: Scope = .everything
	
	@Option(name: [.customLong("docker-volume"), .customShort("v")], help: "The name of the Docker volume used by Cockpit CMS to store data.")
	var dockerVolumeName: String?

	// TODO: Re-establish use of archive directory as variable in all operations.
	// @Option(name: [.customLong("path"), .customShort("p")], help: "The archive directory used to read and write data.")
	// var archivePath: String = "./archive"

	// MARK: Run

	func run() throws {
		print("Running with mode '\(mode.rawValue)', scope '\(scope.rawValue)', supplied volume '\(dockerVolumeName)'.")

		switch mode {
		case .clear:
			runClear()
		case .save:
			try runSave()
		case .restore:
			try runRestore()
		}
	}
	
	private func runClear() {
		clearArchiveDirectories(for: scope)
	}
	
	private func runSave() throws {
		let volumeName = try assertDockerVolumeName()
		
		clearArchiveDirectories(for: scope)
		setUpArchiveDirectories(for: scope)
		saveCockpitToArchive(for: scope, dockerVolumeName: volumeName)
	}
	
	private func runRestore() throws {
		let volumeName = try assertDockerVolumeName()
		
		guard archiveDirectoriesExist(for: scope) else {
			throw PrerequisiteError(errorDescription: "Missing archive directory '\(archiveDirectoryName)' in working directory, can not restore without source.")
		}
		
		restoreCockpitFromArchive(for: scope, dockerVolumeName: volumeName)
	}
	
	// MARK: Prerequisites
	
	private func assertDockerVolumeName() throws -> String {
		guard let volumeName = dockerVolumeName else {
			throw ArgumentError(kind: .missingArgument, errorDescription: "Docker volume not supplied. The Cockpit instance to read from is expected to use a Docker volume for storage.")
		}
		
		guard dockerVolumeExists(volumeName) else {
			throw PrerequisiteError(errorDescription: "Docker volume '\(dockerVolumeName ?? "<None>")' does not exist. The volume used by Cockpit must be created and named beforehand.")
		}
		
		return volumeName
	}
	
}

// MARK: Entry

CockpitBackup.main()
