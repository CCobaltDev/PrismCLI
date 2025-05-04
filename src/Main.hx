package;

import prismcli.CLI;

class Main
{
	public static function main()
	{
		var cli = new CLI("Example CLI 1", "An Example CLI", "1.0.0");

		cli.addArgument("String", "", String);
		cli.addArgument("Int", "", Int);
		cli.addArgument("Float", "", Float);
		cli.addArgument("List", "", List, true);

		cli.addFlag("--none", "");
		cli.addFlag("--str", "", String);
		cli.addFlag("--int", "", Int);
		cli.addFlag("--float", "", Float);
		cli.addFlag("--kvpair", "", KeyValuePair);
		cli.addFlag("--list", "", List);

		cli.run((cli, args, flags) ->
		{
			if (args["String"] != "A")
				cli.print("String");
			if (args["Int"] != 100)
				cli.print("Int");
			if (args["Float"] != 3.141)
				cli.print("Float");
			if (args["List"] == null || (args["List"] : Array<String>)[0] != "A")
				cli.print("List");

			if (!flags.exists("none"))
				cli.print("--none");
			if (flags["str"] != "string")
				cli.print("--str");
			if (flags["int"] != 42)
				cli.print("--int");
			if (flags["float"] != 3.14141414)
				cli.print("--float");
			if (!(flags["kvpair"] : Map<String, Dynamic>)?.exists("boobs") || (flags["kvpair"] : Map<String, Dynamic>)["boobs"] != "oh my")
				cli.print("kvpair");
			if ((flags["list"] : Array<Dynamic>)?.length != 2)
				cli.print("list");

			cli.print('Args:  $args');
			cli.print('Flags: $flags');
		});
	}
}
