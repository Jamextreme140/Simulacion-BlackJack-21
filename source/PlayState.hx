package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.plugin.taskManager.FlxTask;
import flixel.addons.ui.FlxInputText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxTimer;
import lime.app.Application;
import objects.Carta;
import objects.Player;
import utils.ArrayUtil;
#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#end

class PlayState extends FlxState
{
	var first:Bool = true;
	var title:FlxText;
	var playerInput:FlxInputText;
	var text1:FlxText;
	var timesInput:FlxInputText;
	var text2:FlxText;
	var start:FlxButton;
	var mazoDisponible:FlxSprite;
	var timer:FlxTimer;
	var info:FlxText;
	var offs = 30;

	/**
	 * Jugadores 
	 */
	var players:Array<Player>;

	var playersLabel:Array<FlxText>;
	var playersPoints:Array<FlxText>;

	/**
	 * El crupier de la partida
	 */
	var dealer:Player;

	var dealerLabel:FlxText;
	var dealerPoints:FlxText;

	/**
	 * Mazo de cartas actual
	 */
	var mazo:Array<Carta>;

	var excludeCard:Array<Carta> = [];

	/**
	 * Vista de las cartas actuales
	 */
	var vistaMazo:FlxTypedGroup<Carta>;

	public function new()
	{
		super();
		vistaMazo = new FlxTypedGroup<Carta>(52);
		players = new Array();
		timer = new FlxTimer();
	}

	function Simulacion(n:Int, p:Int)
	{
		var ganados = [for (i in 0...p) 0];
		var blackjacks = 0;
		var empates = 0;

		dealer = new Player("Crupier");
		for (i in 0...p)
		{
			players.push(new Player('Jugador ${i + 1}'));
		}
		mazo = generarMazo();
		for (i in mazo)
			vistaMazo.add(i);

		function juego(t:FlxTimer)
		{
			var curPlayerPoints = [for (i in 0...p) 0];
			// var termina:Bool = false;
			if (t.elapsedLoops > 1)
			{
				reset();
				for (i in playersLabel)
					i.color = FlxColor.WHITE;
				dealerPoints.text = "";
				info.text = "";
			}
			var j = 0;
			repartirCartas();
			repartirCartas2da();
			t.active = false;
			new FlxTimer().start(0.7, function(tp:FlxTimer)
			{
				if (j > (p - 1))
				{
					for (i in 0...players.length)
					{
						if (players[i].canPlay)
							curPlayerPoints[i] = players[i].points;
					}
					trace("Crupier");
					dealer.mano.push(mazo.pop());
					FlxTween.tween(dealer.mano[dealer.mano.length - 1], {
						x: dealer.mano[dealer.mano.length - 2].x + offs,
						y: dealer.mano[dealer.mano.length - 2].y
					}, 0.5, {ease: FlxEase.sineInOut});
					dealerPoints.text = ' -> ${dealer.points}';
					tp.active = false;
					new FlxTimer().start(0.5, function(cur:FlxTimer)
					{
						if (ArrayUtil.compareIntInArray(curPlayerPoints.filter(value -> value != 0), dealer.points))
						{
							// Pide carta
							dealer.mano.push(mazo.pop());
							FlxTween.tween(dealer.mano[dealer.mano.length - 1], {
								x: dealer.mano[dealer.mano.length - 2].x + offs,
								y: dealer.mano[dealer.mano.length - 2].y
							}, 0.5, {ease: FlxEase.sineInOut});
							trace('${dealer.ID} - ${dealer.points}');
							dealerPoints.text = ' -> ${dealer.points}';
							// playersPoints[j].text = '${players[j].points}';
						}
						else
						{
							// Se planta
							if (dealer.points >= 22)
							{
								// players[j].canPlay = false;
								// playersLabel[j].color = FlxColor.RED;
								dealerLabel.color = FlxColor.RED;
								var w = calcularPuntos(curPlayerPoints);
								ganados[w - 1] += 1;
								trace('Jugador ${w}');
								info.text = 'Jugador ${w}';
							}
							else if (players[calcularPuntos(curPlayerPoints) - 1].points < dealer.points || everyLose() == p)
							{
								dealerLabel.color = FlxColor.GREEN;
								info.text = 'El Crupier ganó';
								trace('El Crupier ganó');
							}
							else if (ArrayUtil.arrayDuplicates(curPlayerPoints))
							{
								info.text = 'Empate';
								trace('Empate');
								empates++;
							}
							else
							{
								var w = calcularPuntos(curPlayerPoints);
								ganados[w - 1] += 1;
								trace('Jugador ${w}');
								info.text = 'Jugador ${w}';
							}
							tp.active = true;
							cur.cancel();
						}
						tp.active = true;
						cur.cancel();
						if (t.finished && tp.finished)
							openResultState(ganados, blackjacks, n, empates);
					}, 0);
					t.active = true;
					tp.active = true;
					tp.cancel();
					return;
				}
				// for (i in playersLabel)
				//	i.color = FlxColor.WHITE;
				playersLabel[j].color = FlxColor.LIME;
				tp.active = false;

				new FlxTimer().start(0.5, function(cur:FlxTimer)
				{
					if (players[j].hasBlackjack && cur.elapsedLoops == 1)
					{
						trace("BlackJack!");
						// players[j].points = 21;
						playersPoints[j].text = '${players[j].points}';
						blackjacks++;
						j++;
						tp.active = true;
						cur.cancel();
					}
					else if (FlxG.random.bool() && players[j].points < 22)
					{
						// Pide carta
						players[j].mano.push(mazo.pop());
						FlxTween.tween(players[j].mano[players[j].mano.length - 1], {
							x: players[j].mano[players[j].mano.length - 2].x + offs,
							y: players[j].mano[players[j].mano.length - 2].y
						}, 0.5, {ease: FlxEase.sineInOut});
						trace('${players[j].ID} - ${players[j].points}');
						playersPoints[j].text = '${players[j].points}';
					}
					else
					{
						// Se planta
						if (players[j].points >= 22)
						{
							players[j].canPlay = false;
							playersLabel[j].color = FlxColor.RED;
						}
						j++;
						tp.active = true;
						cur.cancel();
					}
					// trace('${players[j].ID} - ${players[j].points}');
				}, 0);
			}, p + 1);
			trace("End");
		}

		timer.start(1.8, juego, n);
	}

	function repartirCartas2da()
	{
		if (mazo.length <= 0)
			return;
		for (i in 0...players.length)
		{
			var curCard = mazo.pop();
			excludeCard.push(curCard);
			players[i].mano.push(curCard);
			switch ((i + 1))
			{
				case 1:
					// players[i].mano[0].setPosition(80, 530);
					FlxTween.tween(players[i].mano[1], {x: 80 + offs, y: 530}, 0.5, {ease: FlxEase.sineInOut});
				case 2:
					// players[i].mano[0].setPosition(280, 530);
					FlxTween.tween(players[i].mano[1], {x: 280 + offs, y: 530}, 0.5, {ease: FlxEase.sineInOut});
				case 3:
					// players[i].mano[0].setPosition(480, 530);
					FlxTween.tween(players[i].mano[1], {x: 480 + offs, y: 530}, 0.5, {ease: FlxEase.sineInOut});
				case 4:
					// players[i].mano[0].setPosition(680, 530);
					FlxTween.tween(players[i].mano[1], {x: 680 + offs, y: 530}, 0.5, {ease: FlxEase.sineInOut});
			}
			playersPoints[i].text = '${players[i].points}';
		}
	}

	function repartirCartas()
	{
		trace(mazo.length);
		if (mazo.length <= 0)
			return;
		for (i in 0...players.length)
		{
			var curCard = mazo.pop();
			excludeCard.push(curCard);
			players[i].mano.push(curCard);
			switch ((i + 1))
			{
				case 1:
					// players[i].mano[0].setPosition(80, 530);
					FlxTween.tween(players[i].mano[0], {x: 80, y: 530}, 0.5, {ease: FlxEase.sineInOut});
				case 2:
					// players[i].mano[0].setPosition(280, 530);
					FlxTween.tween(players[i].mano[0], {x: 280, y: 530}, 0.5, {ease: FlxEase.sineInOut});
				case 3:
					// players[i].mano[0].setPosition(480, 530);
					FlxTween.tween(players[i].mano[0], {x: 480, y: 530}, 0.5, {ease: FlxEase.sineInOut});
				case 4:
					// players[i].mano[0].setPosition(680, 530);
					FlxTween.tween(players[i].mano[0], {x: 680, y: 530}, 0.5, {ease: FlxEase.sineInOut});
			}

			playersLabel[i].text = '${players[i].ID}';
		}
		var curCard = mazo.pop();
		excludeCard.push(curCard);
		dealer.mano.push(curCard);
		// dealer.mano[0].setPosition(376, 131);
		FlxTween.tween(dealer.mano[0], {x: 376, y: 131}, 0.5, {ease: FlxEase.sineInOut});
	}

	function generarMazo():Array<Carta>
	{
		var exclude:Array<String> = [];
		var _mazo:Array<Carta> = [];
		var j = 0;
		while (j < 52)
		{
			var valor = {palo: "", numero: ""};
			var nPalo = Math.random();
			var nNumero = Math.random();
			// Palo
			if (nPalo < 0.25)
				valor.palo = "Corazones";
			else if (nPalo > 0.25 && nPalo < 0.5)
				valor.palo = "Diamantes";
			else if (nPalo > 0.5 && nPalo < 0.75)
				valor.palo = "Picas";
			else
				valor.palo = "Treboles";
			// Numero
			if (nNumero < 0.077)
				valor.numero = "A";
			else if (nNumero > 0.077 && nNumero < 0.154)
				valor.numero = "2";
			else if (nNumero > 0.154 && nNumero < 0.231)
				valor.numero = "3";
			else if (nNumero > 0.231 && nNumero < 0.308)
				valor.numero = "4";
			else if (nNumero > 0.308 && nNumero < 0.385)
				valor.numero = "5";
			else if (nNumero > 0.385 && nNumero < 0.462)
				valor.numero = "6";
			else if (nNumero > 0.462 && nNumero < 0.538)
				valor.numero = "7";
			else if (nNumero > 0.538 && nNumero < 0.615)
				valor.numero = "8";
			else if (nNumero > 0.615 && nNumero < 0.691)
				valor.numero = "9";
			else if (nNumero > 0.692 && nNumero < 0.769)
				valor.numero = "10";
			else if (nNumero > 0.769 && nNumero < 0.846)
				valor.numero = "J";
			else if (nNumero > 0.846 && nNumero < 0.923)
				valor.numero = "Q";
			else
				valor.numero = "K";
			if (exclude.contains('${valor.palo}${valor.numero}'))
				continue;

			exclude.push('${valor.palo}${valor.numero}');

			_mazo.push(new Carta(mazoDisponible.x, mazoDisponible.y, valor));
			// vistaMazo.add(_mazo[j]);
			j++;
		}
		return _mazo;
	}

	function reset()
	{
		#if hl
		Gc.enable(true);
		#end
		for (i in players)
		{
			FlxDestroyUtil.destroyArray(i.mano);
			i.mano.splice(0, i.mano.length);
			i.setDefault();
		}
		FlxDestroyUtil.destroyArray(dealer.mano);
		// players.splice(0, players.length);
		dealer.mano.splice(0, dealer.mano.length);
		dealer.mano = [];
		#if cpp
		Gc.run(true);
		#elseif hl
		Gc.major();
		#end
	}

	function calcularPuntos(arr:Array<Int>)
	{
		var l = arr[0];
		var p = 1;
		for (k in 1...arr.length)
		{
			if (l < arr[k])
			{
				l = arr[k];
				p = k + 1;
			}
		}
		return p;
	}

	function everyLose()
	{
		var a = 0;
		for (i in players)
		{
			if (!i.canPlay)
				a++;
		}
		return a;
	}

	function isBlackJack(arr:Array<Carta>)
	{
		var carta1 = arr[0];
		var carta2 = arr[1];
		trace('${carta1.curName} - ${carta2.curName}');
		if ((carta1.isAs && carta2.points == 10) || (carta2.isAs && carta1.points == 10))
			return true;
		return false;
	}

	function onClick()
	{
		var n = Std.parseInt(timesInput.text);
		var p = Std.parseInt(playerInput.text);
		if (p < 2 || p > 4)
		{
			Application.current.window.alert("El numero de jugadores debe entre 2, 3 y 4", "No. de Jugadores Invalido");
			return;
		}
		else
		{
			trace("Starting...");
			if (!first)
			{
				players.splice(0, players.length);
			}
			Simulacion(n, p);
			/*
				new FlxTimer().start(2, function(t:FlxTimer)
				{
					reset();
				});
			 */
		}
	}

	function openResultState(w:Array<Int>, b:Int, j:Int, e:Int)
	{
		openSubState(new ResultState(w, b, j, e));
	}

	override public function create()
	{
		super.create();
		title = new FlxText(0, 0, 0, "BlackJack", 48);
		title.color = FlxColor.GRAY;
		title.screenCenter();
		add(title);

		text1 = new FlxText(10, 10, 0, "¿Cuantos juegos quieres jugar?", 16);
		add(text1);
		timesInput = new FlxInputText(10, 35, 150, '', 16);
		add(timesInput);

		text2 = new FlxText(text1.x + text1.width + 40, text1.y, 0, "No. Jugadores", 16);
		add(text2);
		playerInput = new FlxInputText(text2.x, timesInput.y, 50, '4', 16);
		add(playerInput);

		start = new FlxButton(text2.x + text2.width + 40, playerInput.y, "Iniciar", onClick);
		// start.screenCenter(FlxAxes.X);
		add(start);

		add(vistaMazo);

		mazoDisponible = new FlxSprite(text1.x, text1.y + text1.height + 50).loadGraphic("assets/images/Card_default.png");
		mazoDisponible.scale.set(0.5, 0.5);
		mazoDisponible.updateHitbox();
		add(mazoDisponible);

		playersLabel = [
			new FlxText(80, 665, 0, "", 16),
			new FlxText(280, 665, 0, "", 16),
			new FlxText(480, 665, 0, "", 16),
			new FlxText(680, 665, 0, "", 16)
		];
		for (i in playersLabel)
			add(i);

		playersPoints = [
			new FlxText(80, 665 + playersLabel[0].height, 0, "", 16),
			new FlxText(280, 665 + playersLabel[1].height, 0, "", 16),
			new FlxText(480, 665 + playersLabel[2].height, 0, "", 16),
			new FlxText(680, 665 + playersLabel[3].height, 0, "", 16)
		];

		for (i in playersPoints)
			add(i);

		dealerLabel = new FlxText(410, 104, 0, "Crupier/Dealer", 16);
		add(dealerLabel);
		dealerPoints = new FlxText(dealerLabel.x + dealerLabel.width + 20, dealerLabel.y, 0, "", 16);
		add(dealerPoints);

		info = new FlxText(10, 400, 0, "", 16);
		add(info);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (timesInput.hasFocus || playerInput.hasFocus)
		{
			FlxG.sound.volumeDownKeys = FlxG.sound.volumeUpKeys = FlxG.sound.muteKeys = null;
		}
		else
		{
			FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];
			FlxG.sound.volumeUpKeys = [MINUS, NUMPADPLUS];
			FlxG.sound.muteKeys = [ZERO, NUMPADZERO];
		}
	}
}
