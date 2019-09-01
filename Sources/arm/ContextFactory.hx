package arm;




import iron.object.Object;
import iron.system.Input.Gamepad;

class ContextFactory  {

	public static var main:ContextFactory  = new ContextFactory();

	function new(){

	}

	public function GetGamepad() : Gamepad{
		return iron.system.Input.getGamepad(1);
	}

	public function GetCharacter() : Object{
		return iron.Scene.active.getChild("Character");
	}
}