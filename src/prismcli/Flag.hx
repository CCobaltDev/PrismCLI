package prismcli;

import prismcli.ParseType.FlagParseType;

@:publicFields
@:structInit
class Flag
{
	/**
	 * The name of this flag, to be accessed from `flags`
	 */
	var name:String;

	/**
	 * The description of this flag, shown in `help`
	 */
	var description:String;

	/**
	 * The identifiers used to parse this flag (e.g. `--help`, `-h`)
	 */
	var parseNames:Array<String>;

	/**
	 * The method of parsing this flag
	 */
	var parseType:FlagParseType;
}
