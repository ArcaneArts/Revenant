import 'package:args/command_runner.dart';

void main(List<String> args) =>
    CommandRunner("revenant", "A command-line tool for Revenant")
      ..addCommand(InstallCommand())
      ..run(args);

class InstallCommand extends Command {
  final name = "install";
  final description =
      "Installs the applications according to the revenant.json file";

  InstallCommand() {}

  void run() {}
}
