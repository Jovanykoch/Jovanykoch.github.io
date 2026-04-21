# Jovanykoch's Network Rule Sets and Configurations

This repository serves as a comprehensive collection of network rule sets and configurations primarily designed for proxy tools such as **Surge**, **Loon**, and **Quantumult X (QX)**. It aims to provide optimized and categorized domain lists to enhance network control, privacy, and browsing experience.

## Features

*   **Categorized Rule Sets**: Domain lists are meticulously categorized for various purposes, including direct connections, proxy routing, and ad/tracker blocking.
*   **Multi-Tool Compatibility**: Configurations and rule sets are structured to be compatible with popular network proxy applications.
*   **Optimized for Performance**: Redundant entries are regularly reviewed and removed to ensure lean and efficient rule processing.
*   **Easy Integration**: Designed for straightforward integration via subscription links or direct file import.

## Supported Tools

This repository provides configurations and rule sets for the following applications:

*   **Surge**: Advanced network utility for iOS and macOS.
*   **Loon**: Rule-based proxy utility for iOS.
*   **Quantumult X (QX)**: Powerful network proxy and web developer tool for iOS.

## Rule Categories Overview

The `rules/` directory contains various domain lists, each serving a specific purpose:

| File Name             | Description                                                                 | Policy (Typical) |
| :-------------------- | :-------------------------------------------------------------------------- | :--------------- |
| `adblock.list`        | Domains for ad-blocking and tracker prevention.                             | REJECT           |
| `reject.list`         | Domains to be blocked (e.g., ads, trackers, malicious sites).               | REJECT           |
| `china.list`          | Domains primarily for Mainland China services, routed directly.             | DIRECT           |
| `china_ip.list`       | IP-CIDR list for Mainland China IP ranges.                                  | DIRECT           |
| `proxy.list`          | **Comprehensive Proxy List**: Includes International services, **Microsoft (Full)**, **GitHub**, **OpenAI**, **Telegram**, and **Education** domains. | PROXY            |
| `apple.list`          | Apple-related services (Optimized for MY).                                  | DIRECT           |
| `direct.list`         | A comprehensive list of domains for direct connection.                      | DIRECT           |
| `lan.list`            | Local Area Network (LAN) related domains.                                   | DIRECT           |

> **Note**: `microsoft.list`, `github.list`, `Copilot.list`, and `edu.list` have been merged into `proxy.list` for easier maintenance and better performance.

Similar categorized rule sets can be found within the `loon/rules/` and `qx/rules/` subdirectories, tailored for their respective applications.

## Usage and Subscription

To utilize these rule sets, you can typically subscribe to the raw `.list` files directly within your chosen proxy application (Surge, Loon, QX). For example, to use `proxy.list` in Surge, you would add a rule like:

```
[Rule]
RULE-SET,https://jovanykoch.github.io/rules/proxy.list,Proxy
```

**Important Notes:**
*   Always ensure the correct policy (DIRECT, PROXY, REJECT) is applied according to your needs.
*   The order of rules in your configuration matters. Generally, more specific rules should come before more general ones.
*   Consider using `GEOIP,CN,DIRECT` as a final rule for Mainland China traffic if not explicitly covered by other rules.

## Contribution

Suggestions for improvements, bug reports, or new rule additions are welcome. Please open an issue or submit a pull request.

## License

This repository is intended for personal use and learning purposes. While the configurations are shared publicly, users are responsible for ensuring compliance with all relevant laws and terms of service when using these rule sets. Please respect all relevant licensing when using third-party tools and configurations documented here.
