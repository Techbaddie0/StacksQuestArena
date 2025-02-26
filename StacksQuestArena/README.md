# StacksQuestArena

A blockchain-based game built on the Stacks blockchain, allowing players to register, create characters, and participate in arena battles.

## Overview

StacksQuestArena is a decentralized game where players can:
- Register with a unique username
- Create customizable characters with various attributes
- Level up characters through gameplay (coming soon)
- Battle other players in the arena (coming soon)

The game leverages Stacks blockchain technology to ensure true ownership of in-game assets and transparent gameplay mechanics.

## Smart Contract Structure

The core contract currently implements:

### Data Maps
- `players`: Tracks registered players and their information
- `usernames`: Ensures username uniqueness across the platform
- `characters`: Stores character attributes and ownership information

### Character Attributes
Each character has the following attributes:
- Name: A unique identifier (3-20 UTF-8 characters)
- Health: Base health points (10-100)
- Attack: Attack power (5-50)
- Defense: Defense capability (5-50)
- Level: Character progression tracker (starts at 1)

### Functions

#### Read-Only
- `is-registered`: Check if a wallet is registered
- `is-username-taken`: Verify username availability
- `get-player-info`: Retrieve player details
- `get-character`: Get character information by ID
- `get-player-characters`: List characters owned by a player

#### Public
- `register-player`: Create a new player account with a unique username
- `create-character`: Create a new character with custom attributes

## Getting Started

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) for local development
- A Stacks wallet (like [Hiro Wallet](https://wallet.hiro.so/))

### Development

1. Clone the repository:
```
git clone https://github.com/Techbaddie0/stacks-quest-arena.git
cd stacks-quest-arena
```

2. Test the contract locally:
```
clarinet test
```

3. Deploy to testnet (optional):
```
clarinet deploy --testnet
```

## Roadmap

- [ ] Battle system implementation
- [ ] Character leveling and progression
- [ ] Items and equipment
- [ ] Marketplace integration
- [ ] Team battles and guilds

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

