package prismcli;

import prismcli.ParseType.ArgParseType;
import prismcli.ParseType.FlagParseType;
import prismcli.Command.CommandFunction;

using StringTools;

class CLI
{
	var name:String;
	var description:String;
	var version:String;

	var defaultCommand:Command;
	var commands:Array<Command> = [];
	var arguments:Map<String, Any> = [];
	var flags:Map<String, Any> = [];

	var argInfo:Array<Argument> = [];
	var flagInfo:Array<Flag> = [];

	var helpFlag:Bool;

	public function new(name:String, desc:String, version:String, defaultHelp:Bool = true)
	{
		this.name = name;
		this.description = desc;
		this.version = version;
		helpFlag = defaultHelp;
		if (helpFlag)
			addFlag("--help", "Display help text", None);
	}

	public function run(?exec:CommandFunction):Void
	{
		var args = Sys.args();
		Sys.setCwd(args.pop());

		var flagSearch = [for (flag in flagInfo) flag.name];

		var index = 0;
		var argumentIndex = 0;

		while (index < args.length)
		{
			var arg = args[index];

			if (arg.startsWith("-"))
			{
				if (flagSearch.contains(arg))
				{
					var curFlag = flagInfo[flagSearch.indexOf(arg)];
					var flagName = curFlag.name.replace("-", "");
					flags.set(flagName, switch (curFlag.parseType)
					{
						case None:
							null;
						case String:
							args[++index];
						case Int:
							Std.parseInt(args[++index]);
						case Float:
							Std.parseFloat(args[++index]);
						case KeyValuePair:
							var map:Map<String, Any> = flags[flagName] ?? new Map<String, Any>();
							var name = args[++index];
							var value = null;
							if (name.contains('='))
							{
								value = name.substr(name.indexOf('=') + 1);
								name = name.substr(0, name.length - name.indexOf('=') - 1);
							}
							else
							{
								var next = args[++index];
								if (next == "=")
									next = args[++index];
								if (next.startsWith("="))
									next = next.substr(1);

								value = next;
							}
							map.set(name, value);
							map;
						case List:
							null;
					});
				}
			}
			else if (argumentIndex < argInfo.length)
			{
				var curArg = argInfo[argumentIndex];

				// TODO Error reporting
				var parsed:Any = switch (curArg.parseType)
				{
					case String:
						arg;
					case Int:
						Std.parseInt(arg);
					case Float:
						Std.parseFloat(arg);
					case List:
						var list = [];
						for (i in index...args.length)
						{
							if (args[i].startsWith("-"))
							{
								index = i;
								break;
							}
							list.push(args[i]);
						}
						list;
				};

				arguments.set(curArg.name, parsed);
				argumentIndex++;
			}

			index++;
		}

		if (flags.exists("help") && helpFlag)
		{
			print(help());
			return;
		}

		if (exec != null)
			exec(this, arguments, flags);
	}

	public function addCommand(name:String, desc:String, execute:CommandFunction) {}

	public function help():String
	{
		var str = '${name} v${version} - ${description}\n\n';

		str += 'Usage: ${Sys.programPath().split('/').pop()} ';

		for (arg in argInfo)
		{
			if (!arg.optional)
				str += '[${arg.name}] ';
			else
				str += '(${arg.name})';
		}

		str += "\n\nFlags:\n";

		for (flag in flagInfo)
		{
			str += '${flag.name}'.rpad(' ', 20) + flag.desc + "\n";
		}

		return str;
	}

	public inline function addArgument(name:String, desc:String, parseType:ArgParseType = String, optional:Bool = false)
	{
		argInfo.push({
			name: name,
			desc: desc,
			parseType: parseType,
			optional: optional
		});
	}

	public inline function addFlag(name:String, desc:String, parseType:FlagParseType = None)
	{
		flagInfo.push({
			name: name,
			desc: desc,
			parseType: parseType
		});
	}

	public inline function print(val:Dynamic):Void
	{
		Sys.println(val);
	}
}
