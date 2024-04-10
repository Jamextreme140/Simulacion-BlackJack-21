package utils;

class ArrayUtil
{
	public static inline function last<T>(arr:Array<T>)
	{
		return arr[arr.length - 1];
	}

	public static inline function lastElement<T>(arr:Array<T>)
	{
		return arr.indexOf(last(arr));
	}

	public static function compareIntInArray(arr:Array<Int>, value:Int)
	{
		trace(arr);
		for (i in arr)
		{
			if (i > value)
				return true;
		}
		return false;
	}

	public static function arrayDuplicates<T>(arr:Array<T>)
	{
		for (i in 0...arr.length)
		{
			for (j in (i + 1)...arr.length)
			{
				if (arr[i] == arr[j])
				{
					return true;
				}
			}
		}
		return false;
	}
}
