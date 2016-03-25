/**
 * Various utility functions.
 */
App.Util = (function()
{
	"use strict";
    
	/**
	 * Extends the prototype of an object, but only if it hasn’t already been set.
	 */
	function extend(baseObject, aFunction)
	{
		// 0. check that the baseObject works, first…
		if ((baseObject === undefined) || (baseObject.prototype === undefined))
			return false;

		// 1. start going through our array of functions
		for (var fn in aFunction)
		{
			// a. check
			if (!aFunction.hasOwnProperty(fn))
				continue;

			// b. if the function is already defined on the object, bail
			if (baseObject.prototype[fn] !== undefined)
				continue;

			// c. extend
			baseObject.prototype[fn] = aFunction[fn];
		}

		return true;
	}

	return {
		extend: extend
	}
})();
