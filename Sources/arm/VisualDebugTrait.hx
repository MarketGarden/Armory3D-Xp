package arm;

#if arm_debug
import iron.math.Vec2;
import kha.Color;
import kha.System;
import iron.math.Vec4;

class LineDebug {
	public var a:Vec4 = null;
	public var b:Vec4 = null;
	public var color:kha.Color = 0xffff0000;
	public var strength : Float = 1;

	public function new() {}
}

interface IDebug {
	 public function addLine(a:Vec4, b:Vec4, color:Color, strength:Float):Void; 
}

class VisualDebugTrait extends iron.Trait implements IDebug  {
	private var lines:Array<LineDebug> = new Array<LineDebug>();
	public static var instance : IDebug;

	public function new() {
		super();
		this.notifyOnRender2D(this.onRender);
		VisualDebugTrait.instance = this;
	}

	public function addLine(a:Vec4, b:Vec4, color:Color, strength:Float) {
		var line = new LineDebug();
		line.a = a;
		line.b = b;
		line.color = color;
		line.strength = strength;
		this.lines.push(line);
	}

	/**
	 * World To Screen Coords
	 * thread http://forums.armory3d.org/t/worldtoscreencoord-draw-debug-lines-with-2d-api/3467
	 * @param loc
	 * @return Vec2
	 */
	public function WorldToScreen(loc:Vec4):Vec2 {
		var v = new Vec4();
		var cam = iron.Scene.active.camera;
		if (cam != null) {
			v.setFrom(loc);
			v.applyproj(cam.V);
			v.applyproj(cam.P);
		}

		var w = System.windowWidth();
		var h = System.windowHeight();
		return new Vec2((v.x + 1) * 0.5 * w, (-v.y + 1) * 0.5 * h);
	}

	public function onRender(g:kha.graphics2.Graphics) {
		while (this.lines.length > 0) {
			var line = this.lines.pop();
			var aScreen = WorldToScreen(line.a);
			var bScreen = WorldToScreen(line.b);
			g.color = line.color;
			g.drawLine(aScreen.x, aScreen.y, bScreen.x, bScreen.y,line.strength);
		}
	}
}
#end
