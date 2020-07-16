import Foundation
import ArgumentParser

struct CockpitSync: ParsableCommand, VolumePreparer, InVolumeDirectoryPreparer, ArchiveDirectoryPreparer, CockpitSaveOperation, CockpitRestoreOperation {
	
	// MARK: Configuration
	
	static var configuration = CommandConfiguration(
		abstract: "Saves or restores data of a Cockpit CMS instance.",
		discussion: lines(
			"Handles saving and restoring of internal data stores of Cockpit CMS (getcockpit.com),",
			"an open source content management system, developed and maintained by Agentejo.",
			"",
			"Assumes that Cockpit runs in a Docker container with its own dedicated volume mounted",
			"at `/var/www/html/storage` inside the container environment. If the targeted Cockpit instance",
			"runs openly outside of containerization, no special tools are required to save and restore its data."
		)
	)
	
	// MARK: Properties
	
	var workingDirectoryPath: Path? {
		return runInShell("pwd")?.outputString
	}

	var expandedArchivePath: Path? {
		runInShell("realpath '\(archivePath)'")?.outputString
	}

	// MARK: Arguments & Options

	@Argument(help: "The mode of the operation. (options: save|restore|clear)")
	var mode: Mode

	@Option(name: [.long, .short], help: "The scope of the operation. (options: structure|records|everything)")
	var scope: Scope = .everything
	
	@Option(name: [.customLong("docker-volume"), .customShort("v")], help: "The name of the Docker volume used by Cockpit to store data.")
	var dockerVolumeName: String?

	@Option(name: [.customLong("path"), .customShort("p")], help: "The path to the archive directory used to read and write data.")
	var archivePath: String

	// MARK: Run

	func run() throws {
		switch mode {
		case .clear:
			try runClear()
		case .save:
			try runSave()
		case .restore:
			try runRestore()
		}
	}
	
	private func runClear() throws {
		try clearArchiveDirectories(for: scope, in: archivePath)
	}
	
	private func runSave() throws {
		let volumeName = try assertDockerVolumeName()
		let archivePath = expandedArchivePath!
		
		try clearArchiveDirectories(for: scope, in: archivePath)

		// Archive directories
		try setUpArchiveDirectories(for: scope, in: archivePath)

		// Cockpit directories
		if try !inVolumeDirectoriesExist(for: scope, volumeName: volumeName) {
			try setUpInVolumeDirectories(for: scope, volumeName: volumeName)
		}

		try saveCockpitToArchive(for: scope, volumeName: volumeName, archivePath: archivePath)
	}
	
	private func runRestore() throws {
		let volumeName = try assertDockerVolumeName()
		let archivePath = expandedArchivePath!

		// Archive directories
		guard try archiveDirectoriesExist(for: scope, archivePath: archivePath) else {
			throw PrerequisiteError(errorDescription: "Archive directory '\(archivePath)' does not exist, can not restore without source.")
		}

		// Cockpit directories
		if try !inVolumeDirectoriesExist(for: scope, volumeName: volumeName) {
			try setUpInVolumeDirectories(for: scope, volumeName: volumeName)
		}
		
		try restoreDataFromArchive(for: scope, volumeName: volumeName, archivePath: archivePath)
		try setPermissionsInVolume(volumeName: volumeName)
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

CockpitSync.main()
