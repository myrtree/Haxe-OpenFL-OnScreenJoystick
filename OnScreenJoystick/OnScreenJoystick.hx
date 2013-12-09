/* written by Dmitriy Maslennikov
   maslennikovDA@gmail.com
*/

package onScreenJoystick;

import flash.display.Sprite;
import motion.Actuate;
import flash.events.Event;
import flash.events.TouchEvent;
import flash.events.MouseEvent;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;

class OnScreenJoystick extends Sprite {
	private var stick: Sprite;
	private var background: Sprite;

	private var joystickXPos: Int;
	private var joystickYPos: Int;
	private var backRadius: Int;
	private var stickRadius: Int;
	private var backColor: Int;
	private var stickColor: Int;
	private var backLineThickness: Int;
	private var stickLineThickness: Int;
	private var backLineColor: Int;
	private var stickLineColor: Int;

	private var backXCenter: Float;
	private var backYCenter: Float;

	private var strengthMult: Float;
	private var maxStrength: Float;

	private var cacheOffsetX: Float;
	private var cacheOffsetY: Float;
	private var cacheStrength: Float = 0;
	private var cacheAngle: Float = 0;

	private var touchPointID: Int;
	private var updateCache: Bool = false;
	private var stickX: Float;
	private var stickY: Float;

	public function new(x: Int, y: Int,
		backRadius: Int = 50, stickRadius: Int = 25, maxStrength: Int = 50,
		backColor: Int = 0xF5F5F5, stickColor: Int = 0x636363,
		backLineThickness: Int = 1, stickLineThickness: Int = 1,
		backLineColor: Int = 0xCCCCCC, stickLineColor: Int = 0xCCCCCC) {

		super ();

		this.joystickXPos = x;
		this.joystickYPos = y;
		this.backRadius = backRadius;
		this.stickRadius = stickRadius;
		this.maxStrength = maxStrength;
		this.backColor = backColor;
		this.stickColor = stickColor;
		this.backLineThickness = backLineThickness;
		this.stickLineThickness = stickLineThickness;
		this.backLineColor = backLineColor;
		this.stickLineColor = stickLineColor;

		if(stage == null) {
			// trace('stage == null');
			addEventListener(Event.ADDED_TO_STAGE, this.init);
			return;
		}
		init(null);
	}

	private function init(event: Event) {
		if (event != null) {
			removeEventListener(Event.ADDED_TO_STAGE, this.init);
		}

		background = new Sprite();
		background.graphics.lineStyle(backLineThickness, backLineColor);
		background.graphics.beginFill(backColor);
		background.graphics.drawCircle(backRadius, backRadius, backRadius);
		background.x = joystickXPos;
		background.y = joystickYPos;
		addChild(background);

		backXCenter = background.x + backRadius - stickRadius;
		backYCenter = background.y + backRadius - stickRadius;

		stick = new Sprite();
		stick.graphics.lineStyle(stickLineThickness, stickLineColor);
		stick.graphics.beginFill(stickColor);
		stick.graphics.drawCircle(stickRadius, stickRadius, stickRadius);
		stick.x = background.x + backRadius - stickRadius;
		stick.y = background.y + backRadius - stickRadius;
		addChild(stick);

		strengthMult = maxStrength / backRadius;

		#if mobile
		if(Multitouch.supportsTouchEvents) {
			// trace('Multitouch supported');
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		} else {
			// trace('Multitouch not supported');
		}
		stick.addEventListener(TouchEvent.TOUCH_BEGIN, stick_onTouchBegin);
		background.addEventListener(TouchEvent.TOUCH_BEGIN, stick_onTouchBegin);
		#else
		// trace('Desktop');
		stick.addEventListener(MouseEvent.MOUSE_DOWN, stick_onMouseDown);
		#end
		addEventListener(Event.ENTER_FRAME, stick_onNextFrame);
	}

	public var strength(get, null): Float;

	public var angle(get, null): Float;

	private function get_strength() {
		var strength = distance();
		if(strength > backRadius) {
			strength = backRadius;
		}
		strength *= strengthMult;
		return strength;
	}

	private inline function sqr(x: Float): Float {
		return x * x;
	}

	private inline function get_angle(): Float {
		var angle: Float = (Math.atan2(stickX - backXCenter,
			stickY - backYCenter) + Math.PI / 2) * 180 / Math.PI;
		if(angle < 0) {
			angle += 360;
		}
		return angle;
	}

	private inline function distance(): Float {
		return Math.sqrt(sqr(stickX - backXCenter) + sqr(stickY - backYCenter));
	}

	/* Circle equation: (x-x0)^2 + (y-y0)^2 = r^2
	   Line equation: (y-y0) = M(x-x0) where M = (y1-y0)/(x1-x0)
	   Point = (x0 + r/sqrt(1+M^2), y0 + r/sqrt(1+1/M^2))
	*/
	private function preventIntersection(): Void {
		var xMult: Int = 1;
		if(stickX <= backXCenter) {
			xMult = -1;
		}
		var yMult: Int = 1;
		if(stickY <= backYCenter) {
			yMult = -1;
		}

		var sqr_M: Float = sqr((stickY - backYCenter) / (stickX - backXCenter));
		stick.x = Std.int(backXCenter + xMult * backRadius / Math.sqrt(1 + sqr_M));
		stick.y = Std.int(backYCenter + yMult * backRadius / Math.sqrt(1 + 1 / sqr_M));
	}

	#if mobile
	private function stick_onTouchBegin(event: TouchEvent): Void {
		if(touchPointID != 0) {
			// trace('Already touched');
			return;
		} 
		this.touchPointID = event.touchPointID;
	#else
	private function stick_onMouseDown(event: MouseEvent): Void {
	#end
		cacheOffsetX = stick.x - event.stageX;
		cacheOffsetY = stick.y - event.stageY;
		#if mobile
		stage.addEventListener(TouchEvent.TOUCH_MOVE, stick_onTouchMove);
		stage.addEventListener(TouchEvent.TOUCH_END, stick_onTouchEnd);
		#else
		stage.addEventListener(MouseEvent.MOUSE_MOVE, stick_onMouseMove);
		stage.addEventListener(MouseEvent.MOUSE_UP, stick_onMouseUp);
		#end
	}

	#if mobile
	private function stick_onTouchMove(event: TouchEvent): Void {
		if(touchPointID != event.touchPointID) {
			// trace('Not your touch event, darling');
			return;
		}
	#else
	private function stick_onMouseMove(event: MouseEvent): Void {
	#end
		stickX = event.stageX + cacheOffsetX;
		stickY = event.stageY + cacheOffsetY;

		if(distance() >= backRadius) {
			preventIntersection();
		} else {
			stick.x = stickX;
			stick.y = stickY;
		}
		updateCache = true;
	}

	#if mobile
	private function stick_onTouchEnd(event: TouchEvent): Void {
		if(touchPointID != event.touchPointID) {
			// trace('You are still touched, darling');
			return;
		}
		touchPointID = 0;
		stage.removeEventListener(TouchEvent.TOUCH_MOVE, stick_onTouchMove);
		stage.removeEventListener(TouchEvent.TOUCH_END, stick_onTouchEnd);
	#else
	private function stick_onMouseUp(event: MouseEvent): Void {
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, stick_onMouseMove);
		stage.removeEventListener(MouseEvent.MOUSE_UP, stick_onMouseUp);
	#end
		Actuate.tween(stick, 0, {x: backXCenter, y: backYCenter});
		stickX = backXCenter;
		stickY = backYCenter;
		updateCache = true;
	}

	private function stick_onNextFrame(event: Event) {
		if(updateCache) {
			cacheStrength = get_strength();
			cacheAngle = get_angle();
			updateCache = false;
			// trace('calculated');
		} else {
			// trace('cached');
		}
		dispatchEvent(new OnScreenJoystickEvent('OnScreenJoystickEvent', cacheAngle, cacheStrength));
	}
}
