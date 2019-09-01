package arm;

import iron.object.Transform;
import kha.Color;
import kha.FastFloat;
import armory.trait.physics.bullet.PhysicsWorld.Hit;
import iron.math.Vec4;
import iron.object.Object;

class SmoothZoomTrait extends iron.Trait {
	private var target:iron.object.Object = null;
	private var gotoCamera:iron.object.Object = null;
	private var character:iron.object.Object = null;
	private var zoom:FastFloat = 1;
	private var angle:FastFloat = 0.5;

	public function new() {
		super();

		this.notifyOnUpdate(this.update);
		this.notifyOnInit(this.init);
	}

	function init() {
		this.target = iron.Scene.active.getChild("aim");
		this.gotoCamera = iron.Scene.active.getChild("Goto Camera");
		this.character = iron.Scene.active.getChild("Character");
	}

	function update() {
		var targetpos:Vec4 = this.target.transform.world.getLoc();
		var campos:Vec4 = this.gotoCamera.transform.world.getLoc();
		var orientation:Vec4 = this.gotoCamera.transform.world.getLoc().clone().sub(targetpos); // campos -targetpos

		#if arm_debug
		// var zoomedcampos:Vec4 = targetpos.clone().add(orientation.clone().mult(this.zoom)); // targetpos + orientation*zoom
		VisualDebugTrait.instance.addLine(targetpos, campos, Color.Blue, 2);
		#end

		var corners = new Array<Vec4>();

		corners.push(this.ApplyTransform(this.gotoCamera.transform, 0, 0, 0)); // center
		corners.push(this.ApplyTransform(this.gotoCamera.transform, 0, angle, angle)); // right top
		corners.push(this.ApplyTransform(this.gotoCamera.transform, 0, angle, -angle * 2)); // right bottom
		corners.push(this.ApplyTransform(this.gotoCamera.transform, 0, -angle, -angle * 2)); // left bottom
		corners.push(this.ApplyTransform(this.gotoCamera.transform, 0, -angle, angle)); // left top

		var min:FastFloat = Math.POSITIVE_INFINITY;

		for (corner in corners) {
			var source:Vec4 = targetpos.clone().add(corner.clone().sub(campos)); // targetpos + (t - campos);

			var hit:Hit = this.RayCastFromTo(source, corner);

			if (hit != null) {
				min = Math.min(min, hit.pos.distanceTo(source));
			}

			#if arm_debug
			VisualDebugTrait.instance.addLine(campos, corner, Color.Yellow, 1);
			#end
		}

		if (min < Math.POSITIVE_INFINITY) {
			var targetzoom:FastFloat = min / orientation.length();
			if (zoom < targetzoom) {
				zoom = (targetzoom + zoom) / 2; // ZoomOut
			} else {
				zoom = targetzoom; // ZoomIn
			}
		} else {
			this.ZoomOut(iron.system.Time.delta);
		}

		this.ApplyZoom(targetpos, orientation);
		this.object.transform.buildMatrix();
	}

	private function ApplyZoom(targetpos:Vec4, orientation:Vec4) {
		this.object.transform.loc = targetpos.clone().add(orientation.mult(zoom)); // targetpos + orientation * zoom;
	}

	private function ZoomIn(delta:FastFloat) {
		zoom = Math.max(zoom - delta, 0);
	}

	private function ZoomOut(delta:FastFloat) {
		zoom = Math.min(zoom + delta, 1);
	}

	inline function ApplyTransform(self:Transform, x:FastFloat, y:FastFloat, z:FastFloat) {
		return new Vec4(x, y, z).applymat4(self.world);
	}

	inline function RayCastFromTo(source:Vec4, destination:Vec4):Hit {
		var ret = armory.trait.physics.PhysicsWorld.active.rayCast(source, destination);

		if (ret != null) {
			ret = new Hit(ret.rb, ret.pos.clone(), ret.normal.clone()); // TODO PR, Fix!
			
			#if arm_debug
			VisualDebugTrait.instance.addLine(source, ret.pos, Color.Red, 1);
			#end

		} else {
			#if arm_debug
			VisualDebugTrait.instance.addLine(source, destination, Color.Black, 1);
			#end
		}
		return ret;
	}
}
