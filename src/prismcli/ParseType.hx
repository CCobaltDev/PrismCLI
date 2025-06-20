package prismcli;

enum ArgParseType
{
	/**
	 * Parse the argument as a `String`
	 */
	String;

	/**
	 * Parse the argument as an `Int`
	 */
	Int;

	/**
	 * Parse the argument as a `Float`
	 */
	Float;
}

enum FlagParseType
{
	/**
	 * Don't parse, just set to `true`
	 */
	None;

	/**
	 * Parse the flag as a `String`
	 */
	String;

	/**
	 * Parse the flag as an `Int`
	 */
	Int;

	/**
	 * Parse the flag as a `Float`
	 */
	Float;

	/**
	 * Parse the flag as a `Map` (Can pass the flag multiple times to add to this map)
	 */
	KeyValuePair;

	/**
	 * Parse the flag as an `Array`
	 * @param count The max amount of items to parse
	 */
	List(count:Int);
}
