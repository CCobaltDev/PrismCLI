# PrismCLI

Haxe CLI Framework inspired by [comma](https://github.com/metincetin/comma) and argparse

Primarily created to be used in HaxeBeacon

## Installation

Run `haxelib install prismcli`

## Usage

Basic CLI with no commands

```hx
import prismcli.CLI;

class Main
{
	public static function main():Void
	{
		var cli = new CLI("Basic CLI", "A basic command-less CLI", "1.0.0");
		cli.addDefaults();

		cli.run((cli, args, flags) ->
		{
			cli.print("This is an example CLI.");
		});
	}
}
```

Basic CLI with a command, argument, and flag

```hx
import prismcli.CLI;

class Main
{
	public static function main():Void
	{
		var cli = new CLI("Basic CLI", "A basic CLI with commands", "1.0.0");
		cli.addDefaults();

		var cmd = cli.addCommand("print", "Prints a number", (cli, args, flags) ->
		{
			cli.print("Print command ran - Here's the number. - " + args["number"]);
			if (flags["again"])
				cli.print(args["number"]);
		});
		cmd.addArgument("number", "The number to print", Int);
		cmd.addFlag("again", "Print the number again", ["--again", "-a"], None);

		cli.run();
	}
}
```