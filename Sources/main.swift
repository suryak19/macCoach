// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

// MARK: - Total RAM

let totalMemory = ProcessInfo.processInfo.physicalMemory
let totalMemoryGB = Double(totalMemory) / 1_073_741_824

print("Total RAM: \(String(format: "%.1f", totalMemoryGB)) GB")

// MARK: - Used Memory

func getUsedMemoryGB() -> Double {
    let task = Process()
    task.launchPath = "/usr/bin/vm_stat"
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    guard let output = String(data: data, encoding: .utf8) else { return 0 }
    
    var usedPages: Double = 0
    let lines = output.components(separatedBy: "\n")
    
    for line in lines {
        if line.contains("Pages active") ||
           line.contains("Pages wired down") ||
           line.contains("Pages speculative") {
            
            let numbers = line.components(separatedBy: CharacterSet.decimalDigits.inverted)
                .compactMap { Double($0) }
            
            if let value = numbers.first {
                usedPages += value
            }
        }
    }
    
    let pageSize = 4096.0
    let usedBytes = usedPages * pageSize
    return usedBytes / 1_073_741_824
}

let usedMemoryGB = getUsedMemoryGB()
let usagePercent = (usedMemoryGB / totalMemoryGB) * 100

print("Used RAM: \(String(format: "%.1f", usedMemoryGB)) GB (\(Int(usagePercent))%)")

// MARK: - Top Processes

func getTopProcesses() {
    let task = Process()
    task.launchPath = "/bin/ps"
    task.arguments = ["-axo", "rss=,command="]
    task.environment = ["COLUMNS": "2000"]

    let pipe = Pipe()
    task.standardOutput = pipe

    do {
        try task.run()
    } catch {
        print("Failed to run ps command")
        return
    }

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    guard let output = String(data: data, encoding: .utf8) else { return }

    var appMemory: [String: Double] = [:]

    let lines = output.components(separatedBy: "\n")

    for line in lines {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { continue }

        let parts = trimmed.split(separator: " ", maxSplits: 1)
        if parts.count < 2 { continue }

        guard let rss = Double(parts[0]) else { continue }

        let memoryGB = rss / 1_048_576
        if memoryGB < 0.05 { continue }

        let fullCommand = String(parts[1])

        // Only consider real .app bundles
        if let appRange = fullCommand.range(of: ".app") {
            let appPath = fullCommand[..<appRange.upperBound]
            let appName = URL(fileURLWithPath: String(appPath))
                .deletingPathExtension()
                .lastPathComponent

            appMemory[appName, default: 0.0] += memoryGB
        }
    }

    let sortedApps = appMemory.sorted { $0.value > $1.value }

    print("\nTop Memory Consumers:")
    for (app, memory) in sortedApps.prefix(5) {
        print("- \(app) – \(String(format: "%.2f", memory)) GB")
    }
}





getTopProcesses()

// MARK: - Rule Engine

if usagePercent > 80 {
    print("\n⚠️ High memory usage detected.")
    print("Consider closing one heavy application.")
} else {
    print("\n✅ Memory usage looks fine.")
}


