import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import haxe.ds.Map;
import objects.Carta;

class Cartas extends FlxTypedGroup<Carta>
{
	public var cartas:Map<String, Carta>;

	var cartasGeneradas:Array<String>;
	var indexNumero:Map<String, String> = [
		"A" => "0012", "2" => "0011", "3" => "0010", "4" => "0009", "5" => "0008", "6" => "0007", "7" => "0006", "8" => "0005", "9" => "0004", "10" => "0003",
		"J" => "0002", "Q" => "0001", "K" => "0000"
	];
	var indexNumeroCarta:Array<String> = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"];
	var indexPalo:Array<String> = ["Corazones", "Diamantes", "Picas", "Treboles"];

	public function new()
	{
		super(52);
		cartas = new Map<String, Carta>();
		// generarCartas();
	}

	public function repartirCarta()
	{
		var cartaActual = cartas.get(cartasGeneradas[cartasGeneradas.length - 1]);
		cartas.remove(cartasGeneradas.pop()); // Retira la carta repartida
		return cartaActual;
	}
	/*
		function generarCartas()
		{
			while (cartasGeneradas.length < 53)
			{
				var ranPalo = Math.random();
				var palo:String; // Nombre del palo
				var ranNumero = Math.random();
				var numero:String;
				var numeroSprite:String;
				var numeroCarta:String;
				var carta:FlxSprite;
				var cartaGenerada:String;
				// Palo
				if (ranPalo <= 1 / 4)
					palo = indexPalo[0];
				else if (ranPalo <= 2 / 4)
					palo = indexPalo[1];
				else if (ranPalo <= 3 / 4)
					palo = indexPalo[2];
				else
					palo = indexPalo[3];

				// Numero
				if (ranNumero > 0 && ranNumero < 1 / 13)
				{
					numero = indexNumeroCarta[0];
				}
				else if (ranNumero > 1 / 13 && ranNumero < 2 / 13)
				{
					numero = indexNumeroCarta[1];
				}
				else if (ranNumero > 2 / 13 && ranNumero < 3 / 13)
				{
					numero = indexNumeroCarta[2];
				}
				else if (ranNumero > 3 / 13 && ranNumero < 4 / 13)
				{
					numero = indexNumeroCarta[3];
				}
				else if (ranNumero > 4 / 13 && ranNumero < 5 / 13)
				{
					numero = indexNumeroCarta[4];
				}
				else if (ranNumero > 5 / 13 && ranNumero < 6 / 13)
				{
					numero = indexNumeroCarta[5];
				}
				else if (ranNumero > 6 / 13 && ranNumero < 7 / 13)
				{
					numero = indexNumeroCarta[6];
				}
				else if (ranNumero > 7 / 13 && ranNumero < 8 / 13)
				{
					numero = indexNumeroCarta[7];
				}
				else if (ranNumero > 8 / 13 && ranNumero < 9 / 13)
				{
					numero = indexNumeroCarta[8];
				}
				else if (ranNumero > 9 / 13 && ranNumero < 10 / 13)
				{
					numero = indexNumeroCarta[9];
				}
				else if (ranNumero > 10 / 13 && ranNumero < 11 / 13)
				{
					numero = indexNumeroCarta[10];
				}
				else if (ranNumero > 11 / 13 && ranNumero < 12 / 13)
				{
					numero = indexNumeroCarta[11];
				}
				else if (ranNumero > 12 / 13 && ranNumero < 13 / 13)
				{
					numero = indexNumeroCarta[12];
				}
				numeroSprite = indexNumero.get(numero);

				cartaGenerada = palo + numero; // 'DiamanteA' | 'Trebol10' | ...
				numeroCarta = palo + numeroSprite; // 'Diamante0000'

				if (cartasGeneradas.contains(cartaGenerada))
					continue;

				carta = new FlxSprite().loadGraphic("assets/images/Cartas.png");
				carta.animation.addByNames(numero, [numeroCarta]);
				add(carta);
				carta.animation.play(numero);

				cartas.set(numero, carta);
				cartasGeneradas.push(cartaGenerada);
				// carta.animation.play(numero);
			}
		}
	 */
}
