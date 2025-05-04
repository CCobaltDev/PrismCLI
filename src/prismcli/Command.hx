package prismcli;

typedef CommandFunction = (cli:CLI, args:Map<String, Any>, flags:Map<String, Any>) -> Void;

@:publicFields
class Command
{
	var name:String;
	var desc:String;
	var execute:CommandFunction;
	// function addArgument(name:String, desc:String, parseType:ParseType = String) {}
	// function addFlag(name:String, shortName:String, desc:String, parseType:ParseType = String) {}
}
