part of json_rpc;

/**
 * JSON-RPC client.
 *
 * JSON-RPC is a lightweight remote procedure call protocol.
 *
 * http://json-rpc.org/wiki/specification
 */

final _libraryLogger = new Logger('json_rpc');
final JSON_TO_BYTES = JSON.fuse(UTF8);


class JsonRpcClient {
  String uri;

  HttpClient _client = new HttpClient();

  /** [RFC 4627](http://tools.ietf.org/html/rfc4627) */
  static const String JSON_MIME_TYPE = 'application/json';

  /** JSON-RPC version. */
  static const String JSON_RPC_VERSION = '2.0';

  JsonRpcClient(this.uri);

  /**
   * method - A String containing the name of the method to be invoked.
   * params - A List or Map of objects to pass as arguments to the method.
   * id - The request id. This can be of any type. It is used to match the response with the request that it is replying to.
   */
  Future call(String method, params, [id]) { // TODO: rename to request?

    final payload = JSON.encode({
      'jsonrpc': JSON_RPC_VERSION,
      'method': method,
      'params': params is List || params is Map ? params : [params],
      'id': id != null ? id : new DateTime.now().millisecondsSinceEpoch});

    final completer = new Completer(),
          conn = _client.postUrl(Uri.parse(uri)).then(
              (HttpClientRequest req) {
                _libraryLogger.fine("payload is $payload");
                req.headers.contentType= new ContentType('application', 'json', charset: "utf-8");
                req.contentLength = UTF8.encode(payload).length;
                req.write(payload);
                req.close();

                req.done.then(
                    (HttpClientResponse resp) {
                      resp.listen(
                        (data) {
                          var z = new String.fromCharCodes(data);
                          _libraryLogger.fine("data is $z");
                          final response = JSON.decode(z);
                          if (response['result'] != null) {
                            completer.complete(response['result']);
                          } else if (response['error'] != null) {
                            completer.completeError("Sent $payload: \nGot $response['error']");
                          }
                        },
                        onError: (e) {
                          _libraryLogger.severe("error: $e");
                        },
                        onDone: () {
                          _client.close();
                        });
                    });
              },
              onError: (e) {
                _libraryLogger.fine("error: $e");
              });

    return completer.future;
  }
}



