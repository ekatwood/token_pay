# token-pay

This web app and app allows users to generate a JavaScript code snippet that can be embedded on any website using an HTML iframe. The JavaScript snippet will display HTML that allows the user to purchase a product using any Solana token of their choice, and it will be automatically swapped using Raydium Protocol into USDC or SOL for the business or merchant to receive as payment for the product.

Phantom Wallet browser extension will be integrated for the user to interact with the Solana blockchain and get a list of all of their Solana public wallet addresses in their Phantom Wallet, so they can select which public wallet address to use for the product being offered.

The user can configure valid coupon codes for the product, using a percent off or amount off, and these details will be stored in a Firebase Firestore database.

token-pay keeps a 0.25% fee on all product transactions made with the generated JavaScript code snippet.

TODO:

Build https://github.com/ekatwood/escrow_subscription so that users can also offer a monthly payment option as well for their product or service.
Buy a custom domain for the project

Estimated work effort:
2 months of development
3 weeks of testing
Marketing for launch once it is through test

The generated JavaScript code snippet could be added to any website, using an iframe element, making this a convenient way for people to receive cryptocurrency payments for products or services on the Solana blockchain.

<img width="648" alt="Screenshot 2025-03-25 at 12 45 29 PM" src="https://github.com/user-attachments/assets/d27a4460-5cc7-40dd-859d-d810b48c9864" />
