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

    // 👇 THIS is where environment variable goes
    task.environment = ["COLUMNS": "1000"]

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

    var processes: [(name: String, memoryGB: Double)] = []

    let lines = output.components(separatedBy: "\n")

    for line in lines {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { continue }

        // Split once: first value is RSS, rest is command
        let parts = trimmed.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
        if parts.count < 2 { continue }

        guard let rss = Double(parts[0]) else { continue }

        let memoryGB = rss / 1_048_576
        if memoryGB < 0.05 { continue } // ignore small processes

        let fullCommand = String(parts[1])

        let appName = URL(fileURLWithPath: fullCommand)
            .deletingPathExtension()
            .lastPathComponent

        processes.append((appName, memoryGB))
    }

    processes.sort { $0.memoryGB > $1.memoryGB }

    print("\nTop Memory Consumers:")
    for process in processes.prefix(5) {
        print("- \(process.name) – \(String(format: "%.2f", process.memoryGB)) GB")
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


