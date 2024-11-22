# NFT Auction Smart Contract

A Starknet smart contract that enables NFT auctions with bidding functionality. This contract allows users to create auctions for NFTs, place bids, and automatically determines the winner based on the highest bid.

## Features

- Create auctions for NFTs with customizable duration and starting price
- Place bids with automatic highest bid tracking
- Automatic auction expiration based on duration
- Event emission for auction creation, bidding, and completion
- View functions for auction status and current highest bid
- Owner-controlled auction finalization

## Prerequisites

- Rust (latest stable version)
- Cairo (latest version)
- Scarb (Starknet's package manager)
- Starkli (CLI tool for Starknet)
- Starknet-devnet (for local development)

## Installation

1. Install Rust:
```bash
# Windows
Visit https://rustup.rs/ and download rustup-init.exe

# Unix-based systems
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

2. Install Scarb:
```bash
# Windows (PowerShell)
curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh

# Unix-based systems
curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh
```

3. Install Starkli:
```bash
# Using cargo
cargo install starkli

# Setup directories
mkdir ~/.starkli-wallets
mkdir ~/.starkli-accounts
```

4. Install Starknet-devnet:
```bash
# Using cargo
cargo install starknet-devnet

# Or using Docker
docker pull shardlabs/starknet-devnet
```

## Project Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd nft-auction
```

2. Build the project:
```bash
scarb build
```

## Contract Structure

```
src/
├── lib.cairo          # Main contract file
└── tests/            # Test files
    └── test_auction.cairo

Scarb.toml           # Project configuration
README.md           # This file
```

## Usage

### Setting Up Local Development Environment

1. Start the local Starknet devnet:
```bash
# Using native installation
starknet-devnet

# Or using Docker
docker run -p 9545:9545 shardlabs/starknet-devnet
```

2. Set up your account and environment:
```bash
# Set environment variables
export STARKNET_RPC=http://localhost:9545
export STARKNET_ACCOUNT=~/.starkli-wallets/account.json
export STARKNET_KEYSTORE=~/.starkli-wallets/deployer.json

# Create keystore and account
starkli signer keystore new ~/.starkli-wallets/deployer.json
starkli account oz init ~/.starkli-wallets/account.json
```

### Deploying the Contract

```bash
starkli deploy ./target/dev/nft_auction_NFTAuction.contract_class.json \
    $ACCOUNT_ADDRESS \
    0x1234... \       # NFT contract address
    u256:1 \         # token_id
    u256:1000000 \   # start_price (in wei)
    u64:3600        # duration (in seconds)
```

### Interacting with the Contract

1. Place a bid:
```bash
starkli invoke <CONTRACT_ADDRESS> place_bid --value 1000000
```

2. Check highest bid:
```bash
starkli call <CONTRACT_ADDRESS> get_highest_bid
```

3. End auction (owner only):
```bash
starkli invoke <CONTRACT_ADDRESS> end_auction
```

## Contract Interface

### Events
- `AuctionCreated`: Emitted when a new auction is created
- `BidPlaced`: Emitted when a new bid is placed
- `AuctionEnded`: Emitted when the auction is finalized

### Functions
- `constructor`: Initializes the auction with NFT details and parameters
- `place_bid`: Allows users to place bids
- `end_auction`: Allows owner to end the auction after duration
- `get_highest_bid`: View current highest bid
- `get_highest_bidder`: View current highest bidder
- `get_auction_end_time`: View auction end time
- `is_active`: Check if auction is still active

## Testing

Run the test suite:
```bash
scarb test
```

## Security Considerations

1. Ensure proper access control for admin functions
2. Verify bid amounts are greater than previous bids
3. Check auction timeframes and status before actions
4. Validate NFT ownership and approvals
5. Consider front-running protection for bids

## License

[Insert License Information]

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## Support

For support, please open an issue in the GitHub repository or contact the maintainers.
