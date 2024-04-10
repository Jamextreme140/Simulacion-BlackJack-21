package objects;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.ds.Map;

class Carta extends FlxSprite
{
	public var valor(get, null):ValorCarta;
	public var points(get, null):Int;
	public var curName(get, null):String;
	public var isAs(get, null):Bool;

	var indexNumero:Map<String, String> = [
		"A" => "0012", "2" => "0011", "3" => "0010", "4" => "0009", "5" => "0008", "6" => "0007", "7" => "0006", "8" => "0005", "9" => "0004", "10" => "0003",
		"J" => "0002", "Q" => "0001", "K" => "0000"
	];

	public function new(x:Float, y:Float, valor:ValorCarta)
	{
		super(x, y);
		this.valor = valor;
		setSprite(valor);
	}

	function setSprite(valor:ValorCarta)
	{
		this.loadGraphic("assets/images/Cartas.png", true);
		this.frames = FlxAtlasFrames.fromSparrow("assets/images/Cartas.png", "assets/images/Cartas.xml");
		this.animation.addByStringIndices(curName, valor.palo, [indexNumero[valor.numero]], ".png", 1, false);
		this.animation.play(curName);
		this.scale.set(0.5, 0.5);
		this.updateHitbox();
	}

	function get_valor():ValorCarta
	{
		return valor;
	}

	function get_curName():String
	{
		return '${valor.palo}${valor.numero}';
	}

	function get_points():Int
	{
		switch (valor.numero)
		{
			case "A":
				return 1;
			case "J" | "Q" | "K":
				return 10;
			case _:
				return Std.parseInt(valor.numero);
		}
		return 0;
	}

	function get_isAs():Bool
	{
		return valor.numero == "A";
	}

	override function destroy()
	{
		super.destroy();
	}
}

typedef ValorCarta =
{
	var palo:String;
	var numero:String;
}
