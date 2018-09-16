
# 
  FABA smart contract

* _Standart_        : ERC20
* _Name_            : FABA 
* _Ticket_          : FABA
* _Decimals_        : 18
* _Emission_        : Mintable
* _Crowdsales_      : 2
* _Fiat dependency_ : Yes
* _Tokens locked_   : Yes

## Smart-contracts description

Contract mint bounty and founders tokens after main sale stage finished. 
Crowdsale contracts have special function to retrieve transferred in errors tokens.
Also crowdsale contracts have special function to direct mint tokens in wei value (featue implemneted to support external pay gateway).

### Contracts contains
1. _FABAToken_ - Token contract
2. _Presale_ - Presale contract
3. _Mainsale_ - ICO contract
4. _Configurator_ - contract with main configuration for production

### How to manage contract
To start working with contract you should follow next steps:
1. Compile it in Remix with enamble optimization flag and compiler 0.4.18
2. Deploy bytecode with MyEtherWallet. Gas 5100000 (actually 5073514).
3. Call 'deploy' function on addres from (3). Gas 4000000 (actually 3979551). 

Contract manager must call finishMinting after each crowdsale milestone!
To support external mint service manager should specify address by calling _setDirectMintAgent_. After that specified address can direct mint FABA tokens by calling _directMint_.

### How to invest
To purchase tokens investor should send ETH (more than minimum 0,0375 ETH) to corresponding crowdsale contract.
Recommended GAS: 250000, GAS PRICE - 21 Gwei.

### Wallets with ERC20 support
1. MyEtherWallet - https://www.myetherwallet.com/
2. Parity 
3. Mist/Ethereum wallet

EXODUS not support ERC20, but have way to export key into MyEtherWallet - http://support.exodus.io/article/128-how-do-i-receive-unsupported-erc20-tokens

Investor must not use other wallets, coinmarkets or stocks. Can lose money.

## Main network configuration

* _Minimal invested limit_      : 0,3 ETH
* _Price_                       : 1 ETH = 600 FABA
* _FABAcompany tokens percent_  : 40% 
* _Team tokens percent_         : 8% 
* _Mentors tokens percent_      : 2% 

* _FABAcompanyTokensWallet_     : 0x96E187bdD7d817275aD45688BF85CD966A80A428
* _Team TokensWallet_           : 0x781b6EeCa4119f7B9633a03001616161c698b2c5

### Links
1. Configurator  https://etherscan.io/address/0x724e1f5c8824875e555b94e819d731f7e02315bd
2. _Deploy_ -    https://etherscan.io/address/0x0a1d2ff7156a48131553cf381f220bbedb4efa37

### Referal system
* _Referer percent_ - 10%
* _Minimal investor value limit to activate referer bonus_ 0.5- ETH
* _Limitations_ - Investor сan't accrue bonus to himself


### Value bonus system

* from 1 ETH bonus 0;



### Crowdsale stages

#### Presale
* _Base price_                 : 600 FABA per ETH
* _Hardcap_                    : (500 ETH)
* _Period_                     : 300 days 
* _Start_                      : •	01.03.2018 00:00:00 GMT
* _Wallet_                     : 0x66CeD6f10d77ae5F8dd7811824EF71ebC0c8aEFf
* _Contract owner_             : 0x66CeD6f10d77ae5F8dd7811824EF71ebC0c8aEFf

#### ICO
* _Base price_                 : 450 FABA per ETH
* _Hardcap_                    : (112500 ETH)
* _Start_                      : •	06.06.2018  00:00:00 GMT
* _Wallet_                     : 0x66CeD6f10d77ae5F8dd7811824EF71ebC0c8aEFf
* _Contract owner_             : 0x66CeD6f10d77ae5F8dd7811824EF71ebC0c8aEFf

_Milestones_
1. 30 days                      : bonus +20% 
2. 30 days                      : bonus +15% 
3. 30 days                      : bonus +10% 


//Token owners will be paid a share of profits from the sale of stakes in the invested companies. Profits will be paid in ETH.

