# 🧠 MacCoach – Lightweight macOS Memory Advisor (CLI)

MacCoach is a simple command-line tool built in Swift that analyzes memory usage on macOS and suggests when you should close heavy applications.

Built initially to optimize my own 4–5 year old MacBook without upgrading hardware.

---

## 🎯 Purpose

Modern Macs slow down primarily due to high memory pressure caused by running multiple heavy applications simultaneously (e.g., Chrome + IntelliJ + Docker).

MacCoach helps you:

- View total RAM
- See current RAM usage
- Identify top memory-consuming applications
- Get smart warnings when memory usage is high

---

## 🚀 Features (v1)

- Reads total system RAM
- Calculates used RAM via `vm_stat`
- Lists top 5 memory-consuming processes
- Sorts them properly (highest to lowest)
- Warns when memory usage exceeds 80%
- Filters insignificant processes (< 50MB)

---

## 🖥 Example Output

Total RAM: 8.0 GB
Used RAM: 6.7 GB (83%)

Top Memory Consumers:

Google Chrome – 2.91 GB

IntelliJ IDEA – 2.43 GB

Docker Desktop – 1.84 GB

⚠️ High memory usage detected.
Consider closing one heavy application



---

## 🛠 Tech Stack

- Swift
- Swift Package Manager
- macOS system commands:
  - `vm_stat`
  - `ps`

---

## 📦 Installation

### 1. Clone Repository

git clone https://github.com/yourusername/MacCoach.git

cd MacCoach


### 2. Build

swift build


### 3. Run


swift run


---

## 🧠 How It Works

### Memory Calculation
- Uses `ProcessInfo.processInfo.physicalMemory` for total RAM
- Uses `vm_stat` to compute active + wired + speculative memory

### Process Analysis
- Uses `ps -axo comm,rss`
- Parses RSS memory
- Converts KB → GB
- Sorts descending
- Displays top 5 processes

### Rule Engine (v1)
If memory usage > 80%:
- Display warning
- Suggest closing heavy apps

---

## 📈 Why I Built This

My MacBook is 4–5 years old and still performs well.
Instead of upgrading hardware, I wanted to:

- Understand real memory bottlenecks
- Optimize usage patterns
- Learn macOS system-level programming
- Build a practical utility for my portfolio

This project reflects practical engineering and system-level thinking.

---

## 🔮 Future Improvements

- Group Chrome helper processes
- Track daily memory spikes
- Log memory pressure history
- Menu bar macOS app version
- AI-based usage pattern detection
- Notification alerts
- LaunchAgent auto-run

---

## 👨‍💻 Author

Surya Konduru

---

## 📜 License

MIT License





