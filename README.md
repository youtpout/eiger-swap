## Contract
[EigerSwap 0x646867e00337f5fBD46634937F0347e4CC806686](https://sepolia.etherscan.io/address/0x646867e00337f5fBD46634937F0347e4CC806686)

Create .env file base on .env example to deploy the contract

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

Will fork ethereum mainnet to launch swap with Uniswapv2 factory and eth/dai pair, doesn't cover all cases

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Deployer.s.sol:DeployerScript --rpc-url sepolia --broadcast --verify -vvvv

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
