import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;

class ResultState extends FlxSubState
{
	var info:FlxText;

	var winners:Array<Int>;
	var blackjacks:Int;
	var emp:Int;
	var juegos:Int;

	public function new(winners:Array<Int>, blackjacks:Int, juegos:Int, emp:Int)
	{
		super(FlxColor.fromRGB(0, 0, 0, 180));
		this.winners = winners;
		this.blackjacks = blackjacks;
		this.emp = emp;
		this.juegos = juegos;
	}

	override function create()
	{
		super.create();

		var text = new FlxText(0, 20);
		text.text = "Resultados Finales";
		text.color = FlxColor.BLUE;
		text.size = 36;
		text.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.CYAN, 3);
		text.screenCenter(FlxAxes.X);

		info = new FlxText();
		info.text = "Jugadas ganadas: ";
		for (i in 0...winners.length)
		{
			info.text += '\nJugador ${i + 1} - ${winners[i]}';
		}
		info.text += '\nBlackjacks ${blackjacks} (${blackjacks / juegos * 100}%)';
		info.size = 24;
		info.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3);
		info.screenCenter();

		var closebtn = new FlxButton(0, 680, "Cerrar", () ->
		{
			close();
		});
		closebtn.x = text.x + text.height;

		add(text);
		add(info);
		add(closebtn);
	}
}
