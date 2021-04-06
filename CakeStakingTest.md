Testnet set up for cake staking 

***Replicate the following test case with your own test account on BSC test net***

--provided by bsc, do not deplicate, just use them as is.
*wbnb	0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd
*router	0xD99D1c33F9fC3444f8101754aBC46c52416550D1

--dev address
*dev	        0x66Df3997298996c363c2bFd23b6ffDC337e106f7
*dev2		0x89418106a7970d14E7Af8fCC69032Df3d069dADc

--deployed addresses on testnet
*cake    0xc4Bea3B6ab8518F02527702294925228223475B7
//mint  at deployment e.g.  1000000000000000000000000 //1 mil

*syrup   0x2Ea6E9294961313Fe1280CDd4006401064533267
//do not mind at deployment

*masterchef  0xf088d241e9bFD6427C82D07985B3e3e244DDCD2A
//set cakeperblock    40000000000000000000 //40  ,startblock 7746555
//transfer cake and syrup ownership to masterchef

*forcetreasury   0x23D3C41ef4354D29dD74D40B86c15d6DB57381f8
//used to receive 4% fee rewards from staking

*cakevault   0x917F4Cf47c6AcE22F6E72436ac7bF27a507144AA  
//set name: CakeVault LP/CVLP
//delay:1
//strategy: use any strategy address, which will be replaced later

*cake strategy   0xB7282a710a840Ac6A69936b7096c8a2134fA6EB4
//go to vault and propose strategy address to 0xB7282a710a840Ac6A69936b7096c8a2134fA6EB4  , then upgrade strategy

--add liquidity. Use router address.
//When testing, make sure the liquidity pool is big enough, and not easily exhausted by swapping reward fees. Be aware of your BNB balance!
//allow router to spend cake before
//add liquidity, e.g. cake:bnb 100000000000000000000000 : 2 bnb, or 100,000 : 2 , minimum output token set at 10%

*cake-bnb pair address   0x509943feBfB2DF7acD9d7eD9C85DeeE5Fc219a77

--deposit
//allow vault to spend cake, then deposit cake to vault, e.g. 1000000000000000000000 //1,000

--harvest
//call Harvest() function in cake strategy, check transaction details to see if success
//owner can set admins; only admins can call Harvest()

//example tx: https://testnet.bscscan.com/tx/0x7b128bd74689175cd3609f529f98e8582aab54304ede1d32be0678fa555a7ac9