package prismcli;

import prismcli.ParseType;
import prismcli.Command;

using StringTools;

class CLI
{
	/**
	 * The name of the CLI
	 */
	public var name:String;

	/**
	 * The description of the CLI
	 */
	public var description:String;

	/**
	 * The version of the CLI
	 */
	public var version:String;

	var defaultCommand:Command;
	var commands:Array<Command> = [];
	var arguments:Map<String, Any> = [];
	var flags:Map<String, Any> = [];

	var argInfo:Array<Argument> = [];
	var flagInfo:Array<Flag> = [];

	@:noCompletion private static var __index:Int = 0;
	@:noCompletion private static var __argumentIndex:Int = 0;

	public function new(name:String, description:String, version:String)
	{
		this.name = name;
		this.description = description;
		this.version = version;
	}

	/**
	 * Runs the CLI. Parses arguments and flags, and runs the command.
	 * @param exec An optional function for command-less CLIs
	 */
	public function run(?exec:CommandFunction):Void
	{
		var args = Sys.args();
		Sys.setCwd(args.pop());

		if (args.length == 0)
		{
			defaultCommand?.exec(this, [], []);
			if (defaultCommand == null)
			{
				print('No default command specified');
				return;
			}
		}

		var flagSearch:Map<String, Int> = [];
		for (i => flag in flagInfo)
			for (name in flag.parseNames)
				flagSearch.set(name, i);

		while (__index < args.length)
		{
			var arg = args[__index];

			if (flagSearch.exists(arg))
			{
				var curFlag = flagInfo[flagSearch[arg]];
				flags.set(curFlag.name, parseFlag(curFlag, arg, args, flags));
			}
			else if (__argumentIndex < argInfo.length)
			{
				var curArg = argInfo[__argumentIndex];

				arguments.set(curArg.name, parseArgument(curArg, arg, args));
				__argumentIndex++;
			}

			__index++;
		}

		if (flagSearch.exists('--help') && flags.exists('help'))
		{
			print(help());
			return;
		}

		if (flagSearch.exists('--version') && flags.exists('version'))
		{
			print('${name} v${version}');
			return;
		}

		if (commands.length > 0)
		{
			var cmds = [for (cmd in commands) cmd.name];
			var cmdArg = args.shift();

			if (cmds.contains(cmdArg))
			{
				var cmd = commands[cmds.indexOf(cmdArg)];

				var required = 0;
				for (arg in cmd.argInfo)
					if (!arg.optional)
						required++;

				var cmdArgs:Map<String, Any> = [];
				var cmdFlags:Map<String, Any> = [];

				__index = 0;
				__argumentIndex = 0;

				var flagSearch:Map<String, Int> = [];
				for (i => flag in cmd.flagInfo)
					for (name in flag.parseNames)
						flagSearch.set(name, i);

				while (__index < args.length)
				{
					var arg = args[__index];

					if (flagSearch.exists(arg))
					{
						var curFlag = cmd.flagInfo[flagSearch[arg]];
						cmdFlags.set(curFlag.name, parseFlag(curFlag, arg, args, cmdFlags));
					}
					else if (__argumentIndex < cmd.argInfo.length)
					{
						var curArg = cmd.argInfo[__argumentIndex];

						cmdArgs.set(curArg.name, parseArgument(curArg, arg, args));
						__argumentIndex++;
					}

					__index++;
				}

				if (required > __argumentIndex)
				{
					print('Not enough arguments');
					return;
				}

				cmd.exec(this, cmdArgs, cmdFlags);
			}
		}

		__index = 0;
		__argumentIndex = 0;

		if (exec != null)
			exec(this, arguments, flags);
	}

	/**
	 * Sets the default command to be executed when none are specified
	 * @param command The command to set as the default
	 */
	public inline function setDefaultCommand(command:Command):Void
	{
		defaultCommand = command;
	}

	/**
	 * Add a command to the CLI
	 * @param name The name of the command
	 * @param description An explanation of the command, shown in the CLI's `help`
	 * @param execute The function to execute when the command is ran
	 * @return The created command, for chaining
	 */
	public function addCommand(name:String, description:String, execute:CommandFunction):Command
	{
		var cmd = new Command(name, description, execute);
		commands.push(cmd);
		return cmd;
	}

	/**
	 * Add an argument to the CLI
	 * @param name The argument name
	 * @param description The argument description, shown in `help`
	 * @param parseType The method of parsing the argument
	 * @param optional Specify if the argument is optional
	 * @return The CLI object, for chaining
	 */
	public function addArgument(name:String, description:String, parseType:ArgParseType = String, optional:Bool = false):CLI
	{
		if (argInfo.length > 0 && argInfo[argInfo.length - 1].optional && !optional)
			throw 'Failed to add argument $name: No required arguments allowed after optional arguments';

		argInfo.push({
			name: name,
			description: description,
			parseType: parseType,
			optional: optional
		});

		return this;
	}

	/**
	 * Adds an optional flag to the CLI
	 * @param name The name of the flag, to be accessed from `flags`
	 * @param description The description of the flag, shown in `help`
	 * @param parseNames The identifiers used to parse the flag (e.g. `--help`, `-h`)
	 * @param parseType The method of parsing the flag
	 * @return The CLI object, for chaining
	 */
	public function addFlag(name:String, description:String, parseNames:Array<String>, parseType:FlagParseType = None):CLI
	{
		flagInfo.push({
			name: name,
			description: description,
			parseNames: parseNames,
			parseType: parseType
		});

		return this;
	}

	/**
	 * Adds `--version`/`-v` and `--help`/`-h` to this CLI
	 */
	public function addDefaults():Void
	{
		addFlag('help', 'Shows this help description', ['--help', '-h'], None);
		addFlag('version', 'Shows the CLI version', ['--version', '-v'], None);
	}

	/**
	 * Creates a help text, showing the name, version, description, commands, arguments, and flags of the CLI
	 * @return String
	 */
	public function help():String
	{
		var str = '${name} v${version} - ${description}\n\n';

		if (argInfo.length > 0)
		{
			str += 'Usage: ${Sys.programPath().split('/').pop()} ';

			for (arg in argInfo)
			{
				if (!arg.optional)
					str += '[${arg.name} - ${Std.string(arg.parseType)}] ';
				else
					str += '(${arg.name} - ${Std.string(arg.parseType)})';
			}

			str += '\n\n';
		}

		if (flagInfo.length > 0)
		{
			str += 'Flags:\n';

			for (flag in flagInfo)
				str += '${flag.name} (${[for (name in flag.parseNames) name].join(', ')})'.rpad(' ', 30) + flag.description + '\n';

			str += '\n';
		}

		if (commands.length > 0)
		{
			str += 'Commands:\n';
			for (cmd in commands)
			{
				str += cmd.name.rpad(' ', 30) + cmd.description + '\n';

				if (cmd.argInfo.length > 0)
					for (arg in cmd.argInfo)
						str += '    ${arg.name}'.rpad(' ', 30) + arg.description + ' - ${Std.string(arg.parseType)}\n';

				if (cmd.flagInfo.length > 0)
					for (flag in cmd.flagInfo)
						str += '    ${flag.name} (${[for (name in flag.parseNames) name].join(', ')})'.rpad(' ', 30)
							+ flag.description
							+ ' - ${Std.string(flag.parseType)}\n';
			}
		}

		return str;
	}

	/**
	 * Print a message to the console
	 * @param val The value to print to the console
	 */
	public inline function print(val:Dynamic):Void
	{
		Sys.println(val);
	}

	private function parseFlag(curFlag:Flag, arg:String, args:Array<String>, flags:Map<String, Any>):Any
	{
		return switch (curFlag.parseType)
		{
			case None:
				true;
			case String:
				args[++__index];
			case Int:
				var val = Std.parseInt(args[++__index]);
				if (val == null)
					print('Failed to parse argument $arg');
				val;
			case Float:
				var val = Std.parseFloat(args[++__index]);
				if (val == Math.NaN)
					print('Failed to parse argument $arg');
				val;
			case KeyValuePair:
				var map:Map<String, Any> = flags[curFlag.name] ?? new Map<String, Any>();
				var name = args[++__index];
				var value = null;
				if (name.contains('='))
				{
					value = name.substr(name.indexOf('=') + 1);
					name = name.substr(0, name.length - name.indexOf('=') - 1);
				}
				else
				{
					var next = args[++__index];
					if (next == '=')
						next = args[++__index];
					if (next.startsWith('='))
						next = next.substr(1);

					value = next;
				}
				map.set(name, value);
				map;
			case List:
				var list = [];
				for (i in __index + 1...args.length)
				{
					if (args[i].startsWith('-'))
						break;

					list.push(args[i]);
				}
				list;
		}
	}

	private function parseArgument(curArg:Argument, arg:String, args:Array<String>):Any
	{
		return switch (curArg.parseType)
		{
			case String:
				arg;
			case Int:
				var val = Std.parseInt(arg);
				if (val == null)
					print('Failed to parse argument $arg');
				val;
			case Float:
				var val = Std.parseFloat(arg);
				if (val == Math.NaN)
					print('Failed to parse argument $arg');
				val;
		};
	}
}
