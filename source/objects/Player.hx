package objects;

class Player
{
	public var ID(get, null):String;
	public var mano(get, set):Array<Carta>;
	public var canPlay(get, set):Bool;
	public var points(get, default):Int;
	public var hasBlackjack(get, null):Bool;

	var _canPlay:Bool = true;
	var _mano:Array<Carta>;

	public function new(ID:String)
	{
		this.ID = ID;
		_mano = new Array();
	}

	function get_ID():String
	{
		return ID;
	}

	function get_mano():Array<Carta>
	{
		return _mano;
	}

	function set_mano(value:Array<Carta>):Array<Carta>
	{
		return _mano = value;
	}

	function get_canPlay():Bool
	{
		return _canPlay;
	}

	function set_canPlay(value:Bool):Bool
	{
		return _canPlay = value;
	}

	function get_points():Int
	{
		if (hasBlackjack)
			return 21;
		var sum = 0;
		for (i in _mano)
		{
			if (i != null)
				sum += i.points;
		}
		return sum;
	}

	public function setDefault()
	{
		_canPlay = true;
	}

	function isBlackJack(arr:Array<Carta>)
	{
		var carta1 = arr[0];
		var carta2 = arr[1];
		if ((carta1.isAs && carta2.points == 10) || (carta2.isAs && carta1.points == 10))
			return true;
		return false;
	}

	function get_hasBlackjack():Bool
	{
		return isBlackJack(_mano);
	}
}
