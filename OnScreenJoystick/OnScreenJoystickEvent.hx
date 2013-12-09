package onScreenJoystick;

import flash.events.Event;

class OnScreenJoystickEvent extends Event {
	private var _angle: Float;
	private var _strength: Float;

	public function new(label: String, angle: Float, strength: Float,
		bubbles: Bool = false, cancelable: Bool = false) {

		super(label, bubbles, cancelable);

		this._angle = angle;
		this._strength = strength;
	}

	public var strength(get, null): Float;

	public var angle(get, null): Float;

	private function get_strength(): Float {
		return this._strength;
	}

	private function get_angle(): Float {
		return this._angle;
	}
}
