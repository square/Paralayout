#!/usr/bin/env swift

import Foundation

// Usage: build.swift <spm|xcode> <platform> [<path_to_xcpretty>]

func execute(commandPath: String, arguments: [String], pipedTo pipeProcess: Process? = nil) throws {
	let task = Process()
	task.launchPath = commandPath
	task.arguments = arguments

	let argumentsString = arguments
		.map { argument in
			if argument.contains(" ") {
				return "\"\(argument)\""
			} else {
				return argument
			}
		}
		.joined(separator: " ")

	if let pipeProcess = pipeProcess, let pipePath = pipeProcess.launchPath {
		let pipe = Pipe()
		task.standardOutput = pipe
		pipeProcess.standardInput = pipe

		print("Launching command: \(commandPath) \(argumentsString) | \(pipePath)")

	} else {
		print("Launching command: \(commandPath) \(argumentsString)")
	}

	task.launch()

	pipeProcess?.launch()

	task.waitUntilExit()

	guard task.terminationStatus == 0 else {
		throw TaskError.code(task.terminationStatus)
	}
}

enum TaskError: Error {
	case code(Int32)
}

enum Platform: String, CustomStringConvertible {
	case iOS_16
	case iOS_15
	case iOS_14
	case iOS_13
	case iOS_12

	var destination: String {
		switch self {
		case .iOS_16:
			return "platform=iOS Simulator,OS=16.1,name=iPhone 14 Pro"
		case .iOS_15:
			return "platform=iOS Simulator,OS=15.5,name=iPhone 13 Pro"
		case .iOS_14:
			return "platform=iOS Simulator,OS=14.4,name=iPhone 12 Pro"
		case .iOS_13:
			return "platform=iOS Simulator,OS=13.7,name=iPhone 11 Pro"
		case .iOS_12:
			return "platform=iOS Simulator,OS=12.4,name=iPhone 5s"
		}
	}

	var derivedDataPath: String {
		return ".build/derivedData/\(rawValue)"
	}

	var description: String {
		return rawValue
	}
}

enum Task: String, CustomStringConvertible {
	case spm
	case xcode

	var workspace: String? {
		switch self {
		case .spm:
			return nil
		case .xcode:
			return "Example/ParalayoutDemo.xcworkspace"
		}
	}

	var scheme: String {
		switch self {
		case .spm:
			return "Paralayout"
		case .xcode:
			return "ParalayoutDemo"
		}
	}

	var configuration: String? {
		switch self {
		case .spm:
			return nil
		case .xcode:
			return "Debug"
		}
	}

	var description: String {
		return rawValue
	}
}

guard CommandLine.arguments.count > 2 else {
	print("Usage: build.swift [spm|xcode] <platform>")
	throw TaskError.code(1)
}

let rawTask = CommandLine.arguments[1]
let rawPlatform = CommandLine.arguments[2]

guard let task = Task(rawValue: rawTask) else {
	print("Received unknown task \"\(rawTask)\"")
	throw TaskError.code(1)
}

guard let platform = Platform(rawValue: rawPlatform) else {
	print("Received unknown platform \"\(rawPlatform)\"")
	throw TaskError.code(1)
}

var xcodeBuildArguments: [String] = []

if let workspace = task.workspace {
	xcodeBuildArguments.append("-workspace")
	xcodeBuildArguments.append(workspace)
}

if let configuration = task.configuration {
	xcodeBuildArguments.append("-configuration")
	xcodeBuildArguments.append(configuration)
}

xcodeBuildArguments.append(
	contentsOf: [
		"-scheme", task.scheme,
		"-sdk", "iphonesimulator",
		"-PBXBuildsContinueAfterErrors=0",
		"-destination", platform.destination,
		"-derivedDataPath", platform.derivedDataPath,
		"ONLY_ACTIVE_ARCH=NO",
		"build",
		"test",
	]
)

let xcpretty: Process?
if CommandLine.arguments.count > 3 {
	xcpretty = .init()
	xcpretty?.launchPath = CommandLine.arguments[3]
} else {
	xcpretty = nil
}

try execute(commandPath: "/usr/bin/xcodebuild", arguments: xcodeBuildArguments, pipedTo: xcpretty)
