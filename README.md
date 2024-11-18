# 🏦 Decentralized Funding Platform

A robust, production-ready smart contract system for decentralized crowdfunding built with Solidity and Foundry.

## 🌟 Features

- **Real-time Price Feeds**: Integrates Chainlink Oracle for accurate ETH/USD conversion
- **Gas Optimized**: Implements gas-efficient patterns including constant/immutable variables
- **Multi-Network Support**: Seamlessly operates on:
  - Ethereum Mainnet
  - Sepolia Testnet
  - Local Development
- **Automated Testing**: Comprehensive test suite with:
  - Unit Tests
  - Integration Tests
  - Forked Network Tests
  - Gas Usage Reports

## 🔧 Technical Architecture

- **Price Feed System**: Chainlink Oracle integration for real-time ETH/USD conversion
- **Smart Contract Security**:
  - Reentrancy protection
  - Access control mechanisms
  - Gas optimization patterns
- **Testing Coverage**: 100% test coverage across critical functions

## 🚀 Quick Start

1. Clone the repository

```
git clone https://github.com/SquilliamX/foundry-fund-me-f23.git

cd foundry-fund-me-f23
```

2. Install dependencies
```
forge install
```


## 💻 Development Commands

### Build
```
forge build
```


### Deploy
```
forge script script/DeployFundMe.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
```


## 📊 Gas Optimization

Track gas usage with:
```
forge snapshot
```


## 🌐 Network Configuration

The platform automatically configures for:
- Ethereum Mainnet
- Sepolia Testnet
- Local Anvil Chain

## 🧪 Testing Philosophy

Our testing strategy encompasses:
1. **Unit Tests**: Individual component testing
2. **Integration Tests**: Cross-component interaction testing
3. **Fork Tests**: Production environment simulation
4. **Gas Optimization Tests**: Performance benchmarking

## 🔐 Security Measures

- Withdrawal pattern implementation
- Access control modifiers
- Secure fund management
- Input validation
- Gas optimization

## 📚 Technical Documentation

### Core Smart Contracts
- `FundMe.sol`: Main funding contract
- `PriceConverter.sol`: ETH/USD conversion logic
- `MockV3Aggregator.sol`: Price feed simulation for testing

### Key Interfaces
- Chainlink Price Feeds
- Custom withdrawal mechanisms
- Gas-optimized fund management

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Open pull request

## 📄 License

MIT

## 🔗 Links



---

Built with 💙 using Foundry and Chainlink.

