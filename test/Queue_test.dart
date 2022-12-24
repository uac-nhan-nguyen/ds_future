import 'package:ds_future/ds_future.dart';
import 'package:test/test.dart';

main() {
  test('Pending job', () async {
    await queue(1, [].map((e) => () async {}));

    final ans = await queue(
        1,
        [1].map((e) => () async {
              return e;
            })).timeout(Duration(seconds: 2));
    expect(ans, [1]);

    final done = [];
    final ans2 = await queue(
        2,
        [2, 1].map((e) => () async {
              await Future.delayed(Duration(milliseconds: 100 * e));
              done.add(e);
              return e;
            }));
    expect(done, [1, 2], reason: "Results should be done independently");
    expect(ans2, [2, 1], reason: "Results should keep same orders");
  });
}
