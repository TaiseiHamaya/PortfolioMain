# Multiplayer Action Game

The project combines a C++ game client and a Rust-based real-time server stack.

## Recruiter Quick View

- Target role: `Rust Game Server Engineer` (multiplayer/real-time backend)
- Core server language: `Rust (edition 2024)`
- Runtime model: `Tokio async TCP` + fixed-tick game loop (`50ms`)
- Protocol: `Protocol Buffers` shared across C++ client and Rust server
- Primary server entry point: `PortfolioGameServer/PortfolioServerZone`

## Demo

### 40-Player Test Snapshot

![40-player test](docs/media/40player-test.gif)

### In-Game Chat Traffic Snapshot

![chat test](docs/media/chat-test.gif)

## Operational Evidence (from Server Logs)

I analyzed production-style run logs located at:
- `C:/Users/k023g/Documents/classwork/3-1/Portfolio/ServerLog`

Summary across the latest 2 captured runs:
- Total accepted TCP connections: `20`
- Longest continuous run: `470,804 ticks` (~`6.54 hours` at 50ms/tick)
- Other observed run length: `55,159 ticks` (~`45.97 min`)

Per-log snapshot:

| Log File | Accepted Connections | WARN | ERROR | Last Tick |
|---|---:|---:|---:|---:|
| `log-2026-01-09-003929.log` | 18 | 0 | 825 | 470,804 |
| `log-2026-01-09-071743.log` | 2 | 0 | 102 | 55,159 |

Representative error categories observed in stress scenarios:
- `Failed to send messages: Kind(WouldBlock)`
	Likely cause: when the peer side is force-terminated, send attempts can repeatedly fail and surface as `WouldBlock` in this log context.
- `ConnectionReset` / `BrokenPipe`
	Likely cause: the peer disconnected or was force-closed while the server was still reading/writing on the same TCP stream.
- `Too many errors, closing connection`
	Likely cause: a defensive threshold in the connection loop is reached after repeated I/O failures, so the session is closed to protect server stability.

These are log-based hypotheses and are being used to guide backpressure and connection-lifecycle improvements.

In these latest two logs, no WARN entries were recorded.

These logs are useful to discuss my server-side debugging focus: backpressure handling, connection lifecycle robustness, and tick-time stability under load.

## What This Repository Contains

- `PortfolioGameClient/`: Windows client (`C++20`, DirectX12, `SyzygyEngine`)
- `PortfolioGameServer/`: Rust server projects
- `proto/`: shared `.proto` schemas and local `protoc`
- `ApplyProto.ps1`: protocol generation script for client and server outputs

## Server Engineering Highlights (Rust)

### 1. Async connection handling on Tokio TCP

- Zone server binds on `0.0.0.0:3215` and runs in async mode
- Code reference: `PortfolioGameServer/PortfolioServerZone/src/app/framework.rs`

### 2. Fixed-tick simulation loop for game updates

- Tick interval is configured at `50ms`
- Per-tick flow includes: receive, accept, process commands, update state, sync transforms, send
- Code reference: `PortfolioGameServer/PortfolioServerZone/src/app/framework.rs`
- Code reference: `PortfolioGameServer/PortfolioServerZone/src/zone/zone.rs`

### 3. Concurrent packet receive across active clients

- Uses `for_each_concurrent` to receive from multiple clients in one tick window
- Code reference: `PortfolioGameServer/PortfolioServerZone/src/zone/zone.rs`

### 4. Entity synchronization with server timestamps

- Broadcasts transform sync packets with microsecond timestamps
- Excludes self-echo when distributing updates
- Code reference: `PortfolioGameServer/PortfolioServerZone/src/zone/zone.rs`

### 5. Cross-language protocol workflow (C++ <-> Rust)

- Shared protobuf schema is generated into both:
- `PortfolioGameClient/Game/Scripts/Proto`
- `PortfolioGameServer/PortfolioServerZone/src/net/proto`
- Script reference: `ApplyProto.ps1`

## Tech Stack

- Server: Rust, Tokio, Futures, Protobuf, Chrono, Simplelog
- Client: C++20, DirectX12, Asio, ImGui, Assimp
- Tooling: Visual Studio 2022, Cargo, PowerShell, MSBuild
- Platform: Windows x64

## Clone

Use recursive clone because this repository contains submodules.

```bash
git clone --recurse-submodules https://github.com/TaiseiHamaya/PortfolioMain
cd PortfolioMain
```

If you already cloned without submodules:

```bash
git submodule update --init --recursive
```

If your environment uses Git LFS for large assets, run:

```bash
git lfs pull
```

## Build and Run

### 1. Run Rust Zone Server

```powershell
cd PortfolioGameServer/PortfolioServerZone
cargo run
```

Default server port:
- `3215`

### 2. Build Client (Visual Studio)

1. Open `PortfolioGameClient/Portfolio.sln`
2. Select `Debug|x64`, `Develop|x64`, or `Release|x64`
3. Build solution

Expected executable output:
- `generated/outputs/x64/<Configuration>/Portfolio.exe`

### 3. Regenerate Protocol Code (Optional)

```powershell
pwsh ./ApplyProto.ps1
```

## Repository Layout

```text
PortfolioMain/
|- PortfolioGameClient/
|- PortfolioGameServer/
|- proto/
|- generated/                  # gitignored local outputs
|- docs/media/
|- ApplyProto.ps1
`- README.md
```

## Notes on Gitignored / Local Test Folders

Some folders are intentionally excluded because they are generated artifacts or local test/runtime data.

Verified examples:
- `/generated`
- `PortfolioGameClient/Game/DevTool/temp/*`
- `PortfolioGameClient/SyzygyEngine/Log/*`
- `PortfolioGameServer/**/target`
- `PortfolioGameServer/PortfolioServerZone/log`

These are required for local development/testing but are not part of tracked source files.
