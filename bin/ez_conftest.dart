import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:args/args.dart';
import 'package:path/path.dart' as p;

Future<Map<String, dynamic>> getInput(String cmd) async {
  var complete = Completer<Map<String, dynamic>>();

  Process.run('sh', ['-c', cmd], runInShell: true).then((pr) {
    var ret = <String, dynamic>{};
    try {
      ret = jsonDecode(pr.stdout.toString()) as Map<String, dynamic>;
    } catch (e) {
      print(e);
    }
    complete.complete(ret);
  });
  return complete.future;
}

void main(List<String> args) async {
  var parser = ArgParser();
  parser.addMultiOption('command',
      abbr: 'c', help: 'The command to generate inpug.');

  parser.addMultiOption('conftest-flag',
      abbr: 'f', help: 'The flags for conftest');

  late ArgResults results;
  try {
    results = parser.parse(args);
  } on FormatException catch (e) {
    print(e.message);
    print(parser.usage);
    exit(1);
  }
  var commands = results['command'] as List<String>;
  var conftestFlags = results['conftest-flag'] as List<String>;
  var inputMap = <String, dynamic>{};
  var inputs = await Future.wait(commands.map(getInput));
  for (var i = 0; i < commands.length; i++) {
    inputMap[inputs[i]['type']] = inputs[i]['data'];
  }
  print(inputMap);

  Process.start('conftest', ['test','-'] + conftestFlags, mode: ProcessStartMode.normal, runInShell: false).then((p) async{
    p.stdin.write(jsonEncode(inputMap));
    await p.stdin.flush();
    await p.stdin.close();
    p.stdout.listen(stdout.add);
    p.stderr.listen(stdout.add);
  });
}
