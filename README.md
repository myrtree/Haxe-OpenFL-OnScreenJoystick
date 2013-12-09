OnScreenJoystick
=====================

Simple and usefull on screen analog joystick written on **haxe**.

Usage example:
```
import onScreenJoystick.*;
...
class Main extends Sprite {
  public function new () {
    super ();
    
    var joystick = new OnScreenJoystick(100, 100, 50, 25, 200);
    // where (100, 100) - joystick position
    // 50 - background radius
    // 25 - stick radius
    // 200 - max stick deflection angle
    addChild(joystick);
    
    joystick.addEventListener('OnScreenJoystickEvent', stickPos);
  }
  
  private function stickPos(event: OnScreenJoystickEvent) {
    // event.angle - direction angle from 0 to 360 degrees
    // event.strength - deflection angle from 0 to maxStrength
    trace('angle: ${event.angle} strength: ${event.strength}');
  }
}

```
