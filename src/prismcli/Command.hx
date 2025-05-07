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
