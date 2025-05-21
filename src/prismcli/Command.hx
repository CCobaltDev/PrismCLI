package prismcli;

import prismcli.ParseType;

typedef CommandFunction = (cli:CLI, args:Map<String, Any>, flags:Map<String, Any>) -> Void;

@:publicFields
class Command
{
	var name:String;
	var description:String;
	var exec:CommandFunction;

	var argInfo:Array<Argument> = [];
	var flagInfo:Array<Flag> = [];

	public function new(name:String, description:String, execute:CommandFunction)
	{
		this.name = name;
		this.description = description;
		this.exec = execute;
	}

	/**
	 * Add an argument to this command
	 * @param name The argument name
	 * @param description The argument description, shown in `help`
	 * @param parseType The method of parsing the argument
	 * @param optional Specify if the argument is optional
	 * @return The command object, for chaining
	 */
	public function addArgument(name:String, description:String, parseType:ArgParseType = String, optional:Bool = false):Command
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
	 * Adds an optional flag to this command
	 * @param name The name of the flag, to be accessed from `flags`
	 * @param description The description of the flag, shown in `help`
	 * @param parseNames The identifiers used to parse the flag (e.g. `--help`, `-h`)
	 * @param parseType The method of parsing the flag
	 * @return The command object, for chaining
	 */
	public function addFlag(name:String, description:String, parseNames:Array<String>, parseType:FlagParseType = None):Command
	{
		flagInfo.push({
			name: name,
			description: description,
			parseNames: parseNames,
			parseType: parseType
		});

		return this;
	}
}
