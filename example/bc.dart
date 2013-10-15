import '../lib/json_rpc.dart';
import 'package:logging_handlers/logging_handlers_shared.dart';
import 'package:logging/logging.dart';

/**
 * A simple JSON-RPC example, connect to bitcoind:
 * bitcoind -rpcuser=user -rpcpassword=password -daemon
 */
void main() {
/*  final client = new JsonRpcClient('http://user:password@127.0.0.1:8332');
  client.call('getinfo').then((result) {
    print(result);
  });*/

  Logger.root.onRecord.listen(new PrintHandler());
  //Logger.root.level = Level.FINE;

  String msg;

  msg = 'Česká mariánská';
  msg = 'Hello, World!';

  final client = new JsonRpcClient('http://127.0.0.1:8080/echo');
  for (String s in ['Česká mariánská', 'Hello, World!']){
  for (String method in ['echo', 'reverse', 'uppercase', 'lowercase']){
  client.call(method, {'msg': s}).then((result) {
    print("$method: $result");
  });
  }
  }
  client.call('na', 'tst').then((result) {
    print("$result");
  });

}
