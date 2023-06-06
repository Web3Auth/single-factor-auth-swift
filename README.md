# Single-Factor-Auth-Swift

> Web3Auth is where passwordless auth meets non-custodial key infrastructure for Web3 apps and wallets. By aggregating OAuth (Google, Twitter, Discord) logins, different wallets and innovative Multi Party Computation (MPC) - Web3Auth provides a seamless login experience to every user on your application.

Web3Auth Single Factor Auth is the SDK that gives you the ability to start with just one key (aka, Single Factor) with Web3Auth, giving you the flexibility of implementing your own UI and UX.


## 📖 Documentation

Checkout the official [Web3Auth Documentation](https://web3auth.io/docs/sdk/web/core/) to get started.


## Features
- Multi network support
- All API's support async await 


## Getting Started
- We support both Swift package manager and cocoapods

init the SingleFactAuth class by passing SingleFactorAuthArgs
```
        let singleFactorAuthArgs = SingleFactorAuthArgs(network: TorusNetwork.TESTNET)
        let singleFactoreAuth = SingleFactorAuth(singleFactorAuthArgs: singleFactorAuthArgs)
```
Use the getKey function to login the user and get the privateKey and public address for the given user
```
            let idToken = try generateIdToken(email: TOURUS_TEST_EMAIL)
        let loginParams = LoginParams(verifier: TEST_VERIFIER, verifierId: TOURUS_TEST_EMAIL, idToken: idToken)
        let torusKey = try await singleFactoreAuth.getKey(loginParams: loginParams)
```

We also have included Session Management in this SDK so call initialize function to get TorusKey value without relogging in the user if a user has an active session it will return the TorusKey struct otherwise it will return nil
```
        if let savedKey = try await singleFactoreAuth.initialize() {
        print(savedKey.getPrivateKey())
        print(savedKey.getPublicAddress())
        }

```

## Requirements
- IOS 14 or above is required 

## 💬 Troubleshooting and Discussions

- Have a look at our [GitHub Discussions](https://github.com/Web3Auth/Web3Auth/discussions?discussions_q=sort%3Atop) to see if anyone has any questions or issues you might be having.
- Checkout our [Troubleshooting Documentation Page](https://web3auth.io/docs/troubleshooting) to know the common issues and solutions
- Join our [Discord](https://discord.gg/web3auth) to join our community and get private integration support or help with your integration.
