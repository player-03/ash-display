AshDisplay
==========

An extension to Ash-Haxe; provides simple classes for displaying objects onscreen.

Sample usage
------------

    //Set up a Tilesheet. Coming soon, possibly: the option to import from [http://draeton.github.io/stitches/](Stitches).
    var tilesheet:Tilesheet = new Tilesheet(Assets.getBitmapData("assets/img/tilesheet.png");
    var tileID:Int = tilesheet.addTileRect(new Rectangle(0, 0, 100, 100));
    
    //Create the Engine and RenderSystem.
    var engine:Engine = new Engine();
    engine.addSystem(new RenderSystem(tilesheet));
    
    //RenderSystem requires at least one Canvas to draw onto. You will probably
    //want to create your own Shape or Sprite rather than using Lib.current.
    engine.addEntity(new Entity().add(new Canvas(Lib.current.graphics)));
    
    //RenderSystem will render any entities that have both a Tile and a
    //Position component.
    engine.addEntity(new Entity().add(new Tile(tileID)).add(new Position()));
