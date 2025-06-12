Here's a comprehensive `README.md` file for your IP Sweeper Pro tool:

```markdown
# IP Sweeper Pro 🚀

**IP Sweeper Pro** is a powerful Bash script designed for network administrators and security professionals to quickly discover active hosts and open ports on a network. With its intuitive interface and robust feature set, it's the ultimate tool for network reconnaissance.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub Release](https://img.shields.io/github/release/networkninja/ip-sweeper-pro.svg)](https://github.com/networkninja/ip-sweeper-pro/releases)
[![Bash Version](https://img.shields.io/badge/Bash-4%2B-blue.svg)](https://www.gnu.org/software/bash/)

## Features ✨

- 🚀 **Fast ping sweeping** across entire subnets
- 🔍 **Port scanning** for common services
- 📊 **Multiple input formats** (CIDR notation or IP ranges)
- 💾 **Save results** to file for later analysis
- 🎨 **Colorized output** for easy reading
- 📈 **Progress tracking** during scans
- 🔧 **Configurable parameters** (timeout, ping count, etc.)
- 📝 **Verbose mode** for debugging
- ⚡ **Fast mode** for quick host discovery

## Installation ⚙️

### Prerequisites
- Bash 4.0 or higher
- Common GNU tools (`ping`, `nc`, `ipcalc`)

### Linux/macOS
```bash
git clone https://github.com/hacker2108/ip-sweeper-pro.git
cd ip-sweeper-pro
chmod +x ipsweep.sh
chmod +x setup.sh
```

### Windows (WSL)
```bash
# Install WSL first if needed
wsl --install
# Then follow Linux instructions above
```

## Usage 🛠️

Basic syntax:
```bash
./ipsweep.sh [OPTIONS]
```

### Examples

**1. Basic network scan:**
```bash
./ipsweep.sh -n 192.168.1.0/24
```

**2. Scan with custom ports:**
```bash
./ipsweep.sh -n 10.0.0.0/24 -p 22,80,443,8080
```

**3. Scan IP range and save results:**
```bash
./ipsweep.sh -r 192.168.1.1 192.168.1.254 -o results.txt
```

**4. Fast scan (host discovery only):**
```bash
./ipsweep.sh -n 192.168.1.0/24 -f
```

**5. Verbose mode:**
```bash
./ipsweep.sh -n 192.168.1.0/24 -v
```

## Options 📋

| Option          | Description                                  | Example                      |
|-----------------|--------------------------------------------|------------------------------|
| `-h`, `--help`  | Show help message                          | `./ipsweep.sh -h`            |
| `-n`, `--network` | Network in CIDR notation                  | `-n 192.168.1.0/24`          |
| `-r`, `--range` | IP range to scan                          | `-r 192.168.1.1 192.168.1.254` |
| `-p`, `--ports` | Ports to scan (comma separated)           | `-p 22,80,443`               |
| `-t`, `--timeout` | Timeout in seconds (default: 1)          | `-t 2`                       |
| `-c`, `--count`  | Ping count (default: 1)                   | `-c 3`                       |
| `-o`, `--output` | Save results to file                      | `-o scan_results.txt`        |
| `-v`, `--verbose` | Show detailed output                      | `-v`                         |
| `-f`, `--fast`   | Fast mode (no port scanning)              | `-f`                         |

## Output Example 📄

```text
  ___ ____   ____  _      _____ ____  ______   ___  _____ 
 |_ _|  _ \ / ___|| |    | ____|  _ \|  _ \ \ / / ||___ / 
  | || |_) | |  _ | |    |  _| | |_) | |_) \ V /| |  |_ \ 
  | ||  __/| |_| || |___ | |___|  __/|  __/ | | | |___| | 
 |___|_|    \____||_____||_____|_|   |_|    |_| |_||____/ 

                     IP SWEEPER PRO v2.0
-----------------------------------------------------
A comprehensive network scanning tool for professionals
-----------------------------------------------------

Network: 192.168.1.0/24
Netmask: 255.255.255.0
Broadcast: 192.168.1.255
Scanning range: 192.168.1.1 - 192.168.1.254

Starting ping sweep...
Scanning IP range: 192.168.1.1 - 192.168.1.254
Ping count: 1, Timeout: 1s

Active host found: 192.168.1.1
Active host found: 192.168.1.5
Active host found: 192.168.1.10

Ping sweep completed. Found 3 active hosts.

Scanning ports on 192.168.1.1...
Port 22 is open
Port 80 is open
Port 443 is open

Scan completed successfully.
```

## Contributing 🤝

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License 📜

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Disclaimer ⚠️

This tool is intended for legal network analysis and security assessment only. The developers assume no liability and are not responsible for any misuse or damage caused by this program.

Always ensure you have proper authorization before scanning any network.

---
💻 **Happy Scanning!** 🔍
```

