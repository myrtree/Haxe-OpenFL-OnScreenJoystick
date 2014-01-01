OnScreenJoystick
=====================

Simple and usefull multi-touch on screen analog joystick written on **Haxe** using **OpenFL**.

Usage example:

Write something like:
```
package ;

import flash.display.Sprite;
import flash.display.Bitmap;
import openfl.Assets;

import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Circle;
import nape.shape.Polygon;
import nape.space.Space;
import nape.constraint.PivotJoint;
import nape.util.ShapeDebug;
import nape.util.Debug;

import flash.events.Event;

import onScreenJoystick.*;

class BasicSimulation extends Sprite {
  var space: Space;
  var debug: Debug;
  public var ball: Body;
  var ball_texture: Sprite;

  function new() {
    super();

    if (stage != null) {
      initialise(null);
    } else {
      addEventListener(Event.ADDED_TO_STAGE, initialise);
    }
  }

  function initialise(event: Event): Void {
    if (event != null) {
      removeEventListener(Event.ADDED_TO_STAGE, initialise);
    }
    var gravity = Vec2.weak(0, 600);
    space = new Space(gravity);
    debug = new ShapeDebug(stage.stageWidth, stage.stageHeight);
    addChild(debug.display);
    setUp();
    stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
  }

  function setUp() {
    var w = stage.stageWidth;
    var h = stage.stageHeight;
  
    var floor = new Body(BodyType.STATIC);
    floor.shapes.add(new Polygon(Polygon.rect(50, (h - 50), (w - 100), 1)));
    floor.shapes.add(new Polygon(Polygon.rect(50, (h - 150), 1, 100)));
    floor.shapes.add(new Polygon(Polygon.rect(w - 50, (h - 150), 1, 100)));
    floor.space = space;

    ball = new Body(BodyType.DYNAMIC);
    ball.shapes.add(new Circle(50));
    ball.position.setxy(w / 2, h / 2);
    ball.angularVel = 10;
    ball.space = space;

    ball_texture = new Sprite();
    var bmp = new Bitmap(Assets.getBitmapData("assets/awesome.png"));
    bmp.x -= bmp.width / 2;
    bmp.y -= bmp.height / 2;
    ball_texture.addChild(bmp);
    addChild(ball_texture);
  }

  function enterFrameHandler(event: Event):Void {
    space.step(1 / stage.frameRate);

    if(ball_texture.x != ball.position.x || ball_texture.y != ball.position.y) {
      ball_texture.x = ball.position.x;
      ball_texture.y = ball.position.y;
      ball_texture.rotation = ball.rotation * 57.2957795;
    }

    debug.clear();
    debug.draw(space);
    debug.flush();
  }
}

class Main extends Sprite {
  var simulation: BasicSimulation;

  private function joyMove(event: OnScreenJoystickEvent) {
    var impulse: Vec2 = Vec2.weak();
    impulse.x = - event.strength * Math.cos(event.angle / 57.2957795);
    impulse.y = event.strength * Math.sin(event.angle / 57.2957795);
    simulation.ball.applyImpulse(impulse);
  }

  public function new () {
    super ();

    var joystick = new OnScreenJoystick(50, 50, 60, 30, 200);
    addChild(joystick);
    simulation = new BasicSimulation();
    addChild(simulation);
    joystick.addEventListener('OnScreenJoystickEvent', joyMove);
  }
}
```
And you will get something like that:
![example](https://github.com/myrtree/haxe-OnScreenJoystick/raw/master/example.png)
