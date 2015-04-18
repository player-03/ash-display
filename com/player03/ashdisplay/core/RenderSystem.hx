package com.player03.ashdisplay.core;

import ash.core.Engine;
import ash.core.Node;
import ash.core.NodeList;
import ash.tools.ListIteratingSystem;
import com.player03.ashdisplay.core.Position;
import com.player03.ashdisplay.core.Rotation;
import com.player03.ashdisplay.core.Tile;
import com.player03.ashdisplay.core.Canvas;
import flash.display.Graphics;
import openfl.display.Tilesheet;

class RenderSystem extends ListIteratingSystem<CanvasNode> {
	private var tileNodeList:NodeList<TileNode>;
	private var rotatingTileNodeList:NodeList<RotatingTileNode>;
	private var activeNodeList:NodeList<Dynamic>;
	
	private var allowRotation:Bool;
	private var smooth:Bool;
	private var flags:Int;
	
	private var tilesheet:Tilesheet;
	private var data:Array<Float>;
	private var rebuildData:Bool = false;
	
	/**
	 * @param	allowRotation Whether the tiles can be rotated. If this is
	 * true, you will have to add a Rotation component to your entities for
	 * them to be rendered.
	 * @param	smooth Whether tiles should be smoothed when drawing.
	 */
	public function new(tilesheet:Tilesheet, allowRotation:Bool = false, smooth:Bool = false) {
		super(CanvasNode, updateNode);
		
		this.tilesheet = tilesheet;
		data = [];
		
		this.allowRotation = allowRotation;
		this.smooth = smooth;
		flags = allowRotation ? Tilesheet.TILE_ROTATION : 0;
	}
	
	public override function addToEngine(engine:Engine):Void {
        super.addToEngine(engine);
		
		if(allowRotation) {
			rotatingTileNodeList = engine.getNodeList(RotatingTileNode);
			activeNodeList = rotatingTileNodeList;
		} else {
			tileNodeList = engine.getNodeList(TileNode);
			activeNodeList = tileNodeList;
		}
		
		activeNodeList.nodeAdded.add(nodeAddedOrRemoved);
		activeNodeList.nodeRemoved.add(nodeAddedOrRemoved);
    }
	
    public override function removeFromEngine(engine:Engine):Void {
		super.removeFromEngine(engine);
		tileNodeList = null;
		rotatingTileNodeList = null;
		
		activeNodeList.nodeAdded.removeAll();
		activeNodeList = null;
	}
	
	private function nodeAddedOrRemoved(node:Dynamic):Void {
		rebuildData = true;
	}
	
	public override function update(time:Float):Void {
		if(rebuildData) {
			rebuildData = false;
			
			var dataLength:Int = Lambda.count(activeNodeList)
				* (allowRotation ? 4 : 3);
			
			if(dataLength < data.length) {
				data.splice(dataLength, data.length - dataLength);
			} else {
				for(i in data.length...dataLength) {
					data.push(0);
				}
			}
		}
		
		super.update(time);
	}
	
	private function updateNode(canvas:CanvasNode, time:Float):Void {
		var i:Int = 0;
		
		if(allowRotation) {
			//Sets of four: [x, y, tileID, rotation]
			for(tileNode in rotatingTileNodeList) {
				data[i] = tileNode.position.x;
				data[i + 1] = tileNode.position.y;
				data[i + 2] = tileNode.image.id;
				data[i + 3] = tileNode.rotation.rotation;
				
				i += 4;
			}
		} else {
			//Sets of three: [x, y, tileID]
			for(tileNode in tileNodeList) {
				data[i] = tileNode.position.x;
				data[i + 1] = tileNode.position.y;
				data[i + 2] = tileNode.image.id;
				
				i += 3;
			}
		}
		
		var surface:Graphics = canvas.canvas.surface;
		surface.clear();
		tilesheet.drawTiles(surface, data, smooth, flags);
	}
}

class TileNode extends Node<TileNode> {
	public var image:Tile;
	public var position:Position;
}

class RotatingTileNode extends Node<RotatingTileNode> {
	public var image:Tile;
	public var position:Position;
	public var rotation:Rotation;
}

class CanvasNode extends Node<CanvasNode> {
	public var canvas:Canvas;
}
