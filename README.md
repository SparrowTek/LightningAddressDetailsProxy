# LightningAddressDetailsProxy
A swift implementation of Alby's [lightning-address-details-proxy](https://github.com/getAlby/lightning-address-details-proxy).  
Infrastructure managed by [Swift Cloud](https://github.com/swift-cloud/swift-cloud).

## Project State
I consider this library complete and ready for production. Unless something changes with how the lightning network functions.

## Contributing

It is always a good idea to **discuss** before taking on a significant task. That said, I have a strong bias towards enthusiasm. If you are excited about doing something, I'll do my best to get out of your way.

By participating in this project you agree to abide by the [Contributor Code of Conduct](CODE_OF_CONDUCT.md).

## Build & Deploy
- clone the repo
- `cp .env.template .env`
- update `.env` with your keys
- deploy `swift run Infra deploy --stage prod`
This code is built to be deployed as an AWS Lambda function. You must provide the `.env` with the proper keys. Setting up an AWS account is outside the scope of this README.