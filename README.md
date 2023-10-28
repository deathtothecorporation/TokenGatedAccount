# TokenGatedAccount

An implementation of the [ERC6551 (TokenBoundAccount)](https://eips.ethereum.org/EIPS/eip-6551) construction, which additionally implements a functionality to "bond" an account to a TGA. This bonded account can act on behalf of the TGA, but can be changed by the owner of the asset and also becomes invalidated upon transfer of the underlying token.

The motivation is to have users be able to act on their mobile wallet as the bonded account in the [Milady OS app](https://github.com/deathtothecorporation/milady-os-contracts), without requiring them to move the underlying authenticating asset (Miladys) onto the phone's wallet.

## Deployed Contracts

* [TBARegistry](https://etherscan.io/address/0x67d12c4db022c543cb7a678f882edc935b898940)
* [TokenGatedAccount implementation](https://etherscan.io/address/0x4584dbf0510e86dcc2f36038c6473b1a0fc5aef3)

The [Milady OS repo](https://github.com/deathtothecorporation/milady-os-contracts)'s audit report includes coverage for these contracts.