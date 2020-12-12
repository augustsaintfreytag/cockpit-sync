*Cockpit Sync* is a command line utility that offers saving and restoring of internal data stores, structure information and asset catalogues of Cockpit CMS (getcockpit.com), an open source content management system, developed and maintained by Agentejo. *Cockpit Sync* is intended to be used for set-ups running Cockpit inside a Docker container with its own volume for storage. It attaches to the volume and copies the selected data for archival or vice versa for restoration.

It can be used as a backup solution, for copying over data from one Cockpit instance to another and to keep a local and a remote/production version of Cockpit in sync; the latter allowing a local draft/test/stage environment for edits on an offline system and only copying complete and checked changes to a public system for release. Without synchronisation, data is commonly edited directly in a production system with brings along an assortment of downsides and risks.

*Cockpit Sync* was developed for internal use across various projects by August Saint Freytag ([augustfreytag.com](https://augustfreytag.com)) and is maintained if needed.

# Prerequisites

*Cockpit Sync* is a dependency-free binary and is built and distributed for both macOS and Linux (`x86_64` only for all platforms). It is written in Swift ([swift.org/about](https://swift.org/about)), an open-source, general-purpose programming language, arising originally out of the Apple ecosystem.

Swift applications can be run as-is without the need for special runtimes on macOS Mojave and newer (from version 10.14.4 upwards, specifically). For older versions of macOS, Apple provides the *Swift 5 Runtime Support for Command Line Tools* which can be installed from the Apple Developer sites at [“More Downloads for Apple Developers”](https://developer.apple.com/download/more/). The Xcode command line tools (or the full Xcode development environment) are not needed to run Swift programs on any machine.

Running the utility on Linux distributions requires Swift and its core libs to be installed ([swift.org/download](https://swift.org/download)) and are usually not included by default. The recommended path to place shared libraries in is at `/usr/lib/swift`. The core library specifically, for instance, would then be found at `/usr/lib/swift/linux/libswiftCore.so`.

# Environments

As an alternative to setting up prerequisites on the target system, Docker can be used to run *Cockpit Sync* without having to install any packages — even though the utility uses Docker itself to read and write files maintained by Cockpit already.

There are many existing images with Swift available, primarily the official `swift:latest` can be used. As Docker itself needs to be accessible from inside the container, a custom `DOCKERFILE` may be used that builds on top of the Swift base image and installs Docker inside the container for the `docker` command to be available. The container also needs to access the Docker socket which can be mounted in to be shared by all environments. As an example of mounting and executing in a one-off container (`--rm`) with TTY mode enabled (`-t`), as follows:

```sh
docker run --rm -t -v /var/run/docker.sock:/var/run/docker.sock myCustomImage cockpit-sync <arguments>
```

Controlling Docker through Docker is not the most common approach; setting up Swift on a Linux machine is generally the recommended way for this guide.

# Usage

The tool runs on the assumption that Cockpit runs in a Docker container with its own dedicated volume mounted at `/var/www/html/storage` inside the container environment. If the targeted Cockpit instance runs openly outside of containerization, no special tools are required to save and restore its data.

On a prepared system, the utility can be run as expected:

```sh
cockpit-sync <arguments>
```

Running the command without any arguments produces a help text with explanations on supported features and parameters. The help text can also be accessed by directly executing `cockpit-sync --help` and can be checked for more information.

The main modes are *save* and *restore*, both of which operating on (1) a destination Docker volume that holds or will hold the data Cockpit CMS works with and (2) an archive folder that either acts as a source of data to be copied over or a destination to receive data for archival.

## Save & Restore

```sh
~/Sites/my-project $
cockpit-sync save -v data_cockpit -a archive
```

The command above runs *Cockpit Sync* in *save mode*, reads and copies all data from the existing Docker volume named “data_cockpit” into the destination folder at “~/Sites/my-project/archive”, based on the provided relative path and the working directory the utility was run from.

```sh
~/Sites/my-project $
cockpit-sync restore -a archive -v data_cockpit
```

This command would run the reverse operation to the one above, reading all data from the provided “archive” directory and copying it back into the Docker volume named “data_cockpit”. *Cockpit-Sync* verifies if the provided volume name exists with `docker` before the operation is actually run.

## Scopes

A save or restore mode command can be run with a specifier for what kind of data should be copied. This allows the independent modification of certain parts of Cockpit’s data volume or the local archive. The available modes are `structure` and `records`, as well as one additional mode, the default value, `everything` that encompasses both in a single operation.

The setting `structure` only touches the form-giving data Cockpit uses, collection/table definitions and their formats. Copying only structure data into the volume of a new Cockpit installation would be usable but not contain any data. Copying only structural information without anything else to update the format specific data models have is possible, though the effects of data orphaned in the process is unknown.

The setting `records` only touches user-input data, including the data inside collections, uploaded and organised assets, as well as authentication data, keys, and preferences. Copying only records without also updating structure is the recommended default mode for automatic pull updates.