**Testnet set up for cake staking**

>*Flow of deposit funds: User calls Deposit() in Vault -> Transfer to Strategy -> Transfer to Masterchef*

>*Flow of withdraw funds: User calls Withdraw() in Vault -> calls Withdraw() in Strategy -> calls Withdraw() or leaveStaking() in Masterchef*

>*Flow of rewards: Admin calls Harvest() in Strategy -> calls Masterchef to send out pending reward to Strategy -> Strategy Swaps 0.5% rewards to WBNB and send to caller as gas subsidy, and sends 4% rewards to Treasury, and deposit the remaining 95.5% rewards to Masterchef*

***Replicate the following test case with your own test account on BSC test net***

Those two are provided by bsc, do not deplicate, just use them as is.

*wbnb:	0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd

*router:	0xD99D1c33F9fC3444f8101754aBC46c52416550D1

***Deployed contract addresses on testnet. Replicate those on your own account.***

*dev address:   0x66Df3997298996c363c2bFd23b6ffDC337e106f7 //Use your own dev address

*cake:    0xc4Bea3B6ab8518F02527702294925228223475B7 //mint some at deployment for testing e.g. 1000000000000000000000000 //i.e. 1 mil //be aware of 18 decimals

*syrup:   0x2Ea6E9294961313Fe1280CDd4006401064533267  //do not mint any at deployment

*masterchef:  0xf088d241e9bFD6427C82D07985B3e3e244DDCD2A //set cakeperblock 40000000000000000000 ie.40, startblock 7746555 

***note to transfer cake and syrup ownership to masterchef***

*forcetreasury:   0x23D3C41ef4354D29dD74D40B86c15d6DB57381f8 //used to receive 4% fee rewards from staking in masterchef

*cakevault:   0x917F4Cf47c6AcE22F6E72436ac7bF27a507144AA   //set name: "CakeVault LP", "CVLP" //set delay:1 //set strategy: use any strategy address, which will be replaced later

***Change hard-coded token addresses in strategy contract***

*cake strategy:   0xB7282a710a840Ac6A69936b7096c8a2134fA6EB4 //go back to vault and propose strategy address to 0xB7282a710a840Ac6A69936b7096c8a2134fA6EB4  , then call upgrade strategy

***Add liquidity. Use router address.***

When testing, make sure the liquidity pool is big enough, and not easily exhausted by swapping reward fees. Be aware of your BNB balance!

After adding liquidity, allow router to spend cake. Use cake contract's Approve().

Settings for adding liquidity, e.g. cake:bnb 100000000000000000000000 : 2 bnb, or 100,000 : 2 . Set minimum output token at 10%, which means you can swap at most 90% of each token in the liquidity pair.

*cake-bnb pair address:   0x509943feBfB2DF7acD9d7eD9C85DeeE5Fc219a77

***Operating vault***

First Allow vault to spend cake, then use vault's deposit() to deposit cake to vault, e.g. input 1000000000000000000000 = 1,000. //18 decimals.

Then call Harvest() function in cake strategy, check transaction details to see if success. Contact owner can set admins; only admins can call Harvest()

example tx: https://testnet.bscscan.com/tx/0x7b128bd74689175cd3609f529f98e8582aab54304ede1d32be0678fa555a7ac9