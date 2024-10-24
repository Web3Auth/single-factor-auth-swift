# Single-Factor-Auth-Swift

> Web3Auth is where passwordless auth meets non-custodial key infrastructure for Web3 apps and wallets. By aggregating OAuth (Google, Twitter, Discord) logins, different wallets and innovative Multi Party Computation (MPC) - Web3Auth provides a seamless login experience to every user on your application.

Web3Auth Single Factor Auth is the SDK that gives you the ability to start with just one key (aka, Single Factor) with Web3Auth, giving you the flexibility of implementing your own UI and UX.


## 📖 Documentation

Checkout the official [Web3Auth Documentation](https://web3auth.io/docs/sdk/core-kit/sfa-ios) to get started.


## Features
- Multi network support
- All API's support async await 

## 🔗 Installation
You can install the SingleFactorAuth Swift using Swift Package Manager.

```
...
dependencies: [
    ...
    .package(url: "https://github.com/Web3Auth/single-factor-auth-swift/", from: "9.0.0")
],
...
```


## Getting Started
Initialize the `SingleFactAuth` class by passing `Web3AuthOptions`

```swift
let singleFactorAuthArgs = SingleFactorAuthArgs(
        clientId: "<Your Client Id>",
        network: Web3AuthNetwork.SAPPHIRE_MAINNET
)
let singleFactoreAuth = SingleFactorAuth(params: Web3AuthOptions)
```

Use the `getKey` function to login the user and get the privateKey and public address for the given user.

```swift
let idToken = try generateIdToken(email: TORUS_TEST_EMAIL)
let loginParams = LoginParams(
        verifier: TEST_VERIFIER, 
        verifierId: TORUS_TEST_EMAIL, 
        idToken: idToken
)

let torusKey = try await singleFactoreAuth.connect(loginParams: loginParams)
```


## Requirements
- iOS 14 or above is required 

## Examples

Checkout the examples for Single Factor Auth Swift in our [examples repository](https://github.com/Web3Auth/web3auth-core-kit-examples/tree/main/single-factor-auth-ios)


## 💬 Troubleshooting and Support

- Have a look at our [Community Portal](https://community.web3auth.io/) to see if anyone has any questions or issues you might be having. Feel free to reate new topics and we'll help you out as soon as possible.
- Checkout our [Troubleshooting Documentation Page](https://web3auth.io/docs/troubleshooting) to know the common issues and solutions.
- For Priority Support, please have a look at our [Pricing Page](https://web3auth.io/pricing.html) for the plan that suits your needs.
