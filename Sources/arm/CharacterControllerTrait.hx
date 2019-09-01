package arm;

import iron.object.Object;
import iron.math.Vec4;
import iron.system.Input.Gamepad;
import armory.trait.physics.RigidBody;

class CharacterControllerTrait extends iron.Trait {
	private var gamepad:Gamepad;
	private var character:Object;
	private var physicsCharacter:RigidBody;

	public function new() {
		super();

		notifyOnInit(this.OnInit);
		notifyOnUpdate(this.OnUpdate);
	}

	function OnInit() {
		this.gamepad = arm.ContextFactory.main.GetGamepad();
		this.character = arm.ContextFactory.main.GetCharacter();
		this.physicsCharacter = this.character.getTrait(RigidBody);
	}

	function OnUpdate() {
		//this.character.transform.move(new Vec4(this.gamepad.leftStick.x, this.gamepad.leftStick.y, 0), 1);

		#if arm_physics
		this.physicsCharacter.applyForce(new Vec4(this.gamepad.leftStick.x, this.gamepad.leftStick.y, 0));
		#end
	}
}
