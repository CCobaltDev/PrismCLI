package prismcli;

import prismcli.ParseType.ArgParseType;

typedef Argument =
{
	var name:String;
	var desc:String;
	var parseType:ArgParseType;
	var optional:Bool;
}
