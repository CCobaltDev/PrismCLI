package prismcli;

import prismcli.ParseType.ArgParseType;

@:publicFields
@:structInit
class Argument
{
	/**
	 * The name of the argument
	 */
	var name:String;

	/**
	 * A short description of the argument
	 */
	var description:String;

	/**
	 * The method of parsing the argument
	 */
	var parseType:ArgParseType;

	/**
	 * If the argument is optional or not. Required arguments can't be placed after optional arguments
	 */
	var optional:Bool;
}
