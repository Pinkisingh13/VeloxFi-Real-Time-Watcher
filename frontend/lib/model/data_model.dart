class DataModel {
  final String id;
  final String rank;
  final String symbol;
  final String name;
  final String supply;
  final String maxSupply;
  final String marketCapUsd;
  final String volumeUsd24Hr;
  final String priceUsd;
  final String changePercent24Hr;
  final String vwap24Hr;
  final String explorer;
  final Map<String, List<String>> tokens;

  DataModel({
    required this.id,
    required this.rank,
    required this.symbol,
    required this.name,
    required this.supply,
    required this.maxSupply,
    required this.marketCapUsd,
    required this.volumeUsd24Hr,
    required this.priceUsd,
    required this.changePercent24Hr,
    required this.vwap24Hr,
    required this.explorer,
    required this.tokens,
  });

  DataModel.fromJson(Map<String, dynamic> json)
    : id = json['id'] ?? '',
      rank = json['rank']?.toString() ?? '',
      symbol = json['symbol'] ?? '',
      name = json['name'] ?? '',
      supply = json['supply'] ?? '',
      maxSupply = json['maxSupply']?.toString() ?? '',
      marketCapUsd = json['marketCapUsd'] ?? '',
      explorer = json['explorer'] ?? '',
      tokens = (json['tokens'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, (value as List<dynamic>).map((e) => e.toString()).toList())
      ) ?? {},
      volumeUsd24Hr = json['volumeUsd24Hr'] ?? '',
      priceUsd = json['priceUsd'] ?? '',
      changePercent24Hr = json['changePercent24Hr'] ?? '',
      vwap24Hr = json['vwap24Hr'] ?? '';
}

// 
// { "id":"bitcoin","rank":"1","symbol":"BTC","name":"Bitcoin","supply":"19965971.000000000000000000","maxSupply":"21000000.000000000000000000","marketCapUsd":"1751239275575.199951171875000000","volumeUsd24Hr":"41020315364.905166625976562500","priceUsd":"87711.199999999997089617","changePercent24Hr":"-2.4410536133077088","vwap24Hr":"88305.90262468117","explorer":"https://blockchain.info/","tokens":{}},

//{"id":"ethereum","rank":"2","symbol":"ETH","name":"Ethereum","supply":"120694996.479289874434471130","maxSupply":null,"marketCapUsd":"355112439491.261047363281250000","volumeUsd24Hr":"16784324919.897981643676757813","priceUsd":"2942.230000000000018190","changePercent24Hr":"-3.768657265601617","vwap24Hr":"2993.9497467216406","explorer":"https://etherscan.io/","tokens":{}}

//{"id":"tether","rank":"3","symbol":"USDT","name":"Tether USDt","supply":"186906835256.838470458984375000","maxSupply":null,"marketCapUsd":"186850763206.261413574218750000","volumeUsd24Hr":"790967708.432154893875122070","priceUsd":"0.999700000000000033","changePercent24Hr":"-0.010002000400078915","vwap24Hr":"0.9996950655319785","explorer":"https://www.omniexplorer.info/asset/31","tokens":{"1":["0xdac17f958d2ee523a2206206994597c13d831ec7"],"10":["0x94b008aa00579c1307b0ef2c499ad98a8ce58e58"],"56":["0x55d398326f99059ff775485246999027b3197955"],"101":["es9vmfrzacermjfrf4h2fyd4kconky11mcce8benwnyb"],"137":["0xc2132d05d31c914a87c6611c10748aeb04b58e8f"],"42161":["0xfd086bc7cd5c481dcc9c85ebe478a1c0b69fcbb9"]}},

//{"id":"binance-coin","rank":"4","symbol":"BNB","name":"BNB","supply":"137734906.460000008344650269","maxSupply":"137734906.460000008344650269","marketCapUsd":"116868711292.168869018554687500","volumeUsd24Hr":"1002382783.422258734703063965","priceUsd":"848.504669555999953445","changePercent24Hr":"-1.8672677319146502","vwap24Hr":"857.0244245803801","explorer":"https://etherscan.io/token/0xB8c77482e45F1F44dE1745F52C74426C631bDD52","tokens":{"1":["0xb8c77482e45f1f44de1745f52c74426c631bdd52"],"56":["0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"]}}
