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
	case iOS_17
	case iOS_18
	case iPadOS_17

	var destination: String {
		switch self {
		case .iOS_17:
			"platform=iOS Simulator,OS=17.5,name=iPhone 15 Pro"
		case .iOS_18:
			"platform=iOS Simulator,OS=18.0,name=iPhone 16 Pro"
		case .iPadOS_17:
			"platform=iOS Simulator,OS=17.5,name=iPad (10th generation)"
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
			return "Example/ParalayoutDemo.xcodeproj"
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
