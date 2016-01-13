package com.codeazur.as3swf
{
	import com.codeazur.as3swf.data.SWFFrameLabel;
	import com.codeazur.as3swf.data.SWFRawTag;
	import com.codeazur.as3swf.data.SWFRecordHeader;
	import com.codeazur.as3swf.data.SWFScene;
	import com.codeazur.as3swf.data.consts.SoundCompression;
	import com.codeazur.as3swf.events.SWFErrorEvent;
	import com.codeazur.as3swf.events.SWFEventDispatcher;
	import com.codeazur.as3swf.events.SWFProgressEvent;
	import com.codeazur.as3swf.events.SWFWarningEvent;
	import com.codeazur.as3swf.factories.ISWFTagFactory;
	import com.codeazur.as3swf.factories.SWFTagFactory;
	import com.codeazur.as3swf.tags.IDefinitionTag;
	import com.codeazur.as3swf.tags.IDisplayListTag;
	import com.codeazur.as3swf.tags.ITag;
	import com.codeazur.as3swf.tags.TagDefineMorphShape;
	import com.codeazur.as3swf.tags.TagDefineSceneAndFrameLabelData;
	import com.codeazur.as3swf.tags.TagEnd;
	import com.codeazur.as3swf.tags.TagFrameLabel;
	import com.codeazur.as3swf.tags.TagJPEGTables;
	import com.codeazur.as3swf.tags.TagPlaceObject;
	import com.codeazur.as3swf.tags.TagPlaceObject2;
	import com.codeazur.as3swf.tags.TagPlaceObject3;
	import com.codeazur.as3swf.tags.TagRemoveObject;
	import com.codeazur.as3swf.tags.TagRemoveObject2;
	import com.codeazur.as3swf.tags.TagSetBackgroundColor;
	import com.codeazur.as3swf.tags.TagShowFrame;
	import com.codeazur.as3swf.tags.TagSoundStreamBlock;
	import com.codeazur.as3swf.tags.TagSoundStreamHead;
	import com.codeazur.as3swf.tags.TagSoundStreamHead2;
	import com.codeazur.as3swf.timeline.Frame;
	import com.codeazur.as3swf.timeline.FrameObject;
	import com.codeazur.as3swf.timeline.Layer;
	import com.codeazur.as3swf.timeline.LayerStrip;
	import com.codeazur.as3swf.timeline.Scene;
	import com.codeazur.as3swf.timeline.SoundStream;
	import com.codeazur.utils.StringUtils;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	import flash.utils.getTimer;

	public class SWFTimelineContainer extends SWFEventDispatcher
	{
		// We're just being lazy here.
		public static var TIMEOUT:int = 50;
		public static var AUTOBUILD_LAYERS:Boolean = false;
		public static var EXTRACT_SOUND_STREAM:Boolean = true;
		
		protected var _tags:Vector.<ITag>;
		protected var _tagsRaw:Vector.<SWFRawTag>;
		protected var _dictionary:Dictionary;
		protected var _scenes:Vector.<Scene>;
		protected var _frames:Vector.<Frame>;
		protected var _layers:Vector.<Layer>;
		protected var _soundStream:SoundStream;

		protected var currentFrame:Frame;
		protected var frameLabels:Dictionary;
		protected var hasSoundStream:Boolean = false;

		protected var enterFrameProvider:Sprite;
		protected var eof:Boolean;

		protected var _tmpData:SWFData;
		protected var _tmpVersion:uint;
		protected var _tmpTagIterator:int = 0;

		protected var _tagFactory:ISWFTagFactory;

		internal var rootTimelineContainer:SWFTimelineContainer;
		
		public var backgroundColor:uint = 0xffffff;
		public var jpegTablesTag:TagJPEGTables;

		public function SWFTimelineContainer()
		{
			_tags = new Vector.<ITag>();
			_tagsRaw = new Vector.<SWFRawTag>();
			_dictionary = new Dictionary();
			_scenes = new Vector.<Scene>();
			_frames = new Vector.<Frame>();
			_layers = new Vector.<Layer>();
		
			_tagFactory = new SWFTagFactory();
			
			rootTimelineContainer = this;
			
			enterFrameProvider = new Sprite();
		}
		
		public function get tags():Vector.<ITag> { return _tags; }
		public function get tagsRaw():Vector.<SWFRawTag> { return _tagsRaw; }
		public function get dictionary():Dictionary { return _dictionary; }
		public function get scenes():Vector.<Scene> { return _scenes; }
		public function get frames():Vector.<Frame> { return _frames; }
		public function get layers():Vector.<Layer> { return _layers; }

		public function get soundStream():SoundStream { return _soundStream; }
		
		public function get tagFactory():ISWFTagFactory { return _tagFactory; }
		public function set tagFactory(value:ISWFTagFactory):void { _tagFactory = value; }
		
		public function getCharacter(characterId:uint):IDefinitionTag {
			var tagIndex:int = rootTimelineContainer.dictionary[characterId];
			if(tagIndex >= 0 && tagIndex < rootTimelineContainer.tags.length) {
				return rootTimelineContainer.tags[tagIndex] as IDefinitionTag;
			}
			return null;
		}
		
		public function parseTags(data:SWFData, version:uint):void {
			var tag:ITag;
			parseTagsInit(data, version);
			while ((tag = parseTag(data)) && tag.type != TagEnd.TYPE) {};
			parseTagsFinalize();
		}
		
		public function parseTagsAsync(data:SWFData, version:uint):void {
			parseTagsInit(data, version);
			enterFrameProvider.addEventListener(Event.ENTER_FRAME, parseTagsAsyncHandler);
		}
		
		protected function parseTagsAsyncHandler(event:Event):void {
			enterFrameProvider.removeEventListener(Event.ENTER_FRAME, parseTagsAsyncHandler);
			if(dispatchEvent(new SWFProgressEvent(SWFProgressEvent.PROGRESS, _tmpData.position, _tmpData.length, false, true))) {
				parseTagsAsyncInternal();
			}
		}
		
		protected function parseTagsAsyncInternal():void {
			var tag:ITag;
			var time:int = getTimer();
			while ((tag = parseTag(_tmpData, true)) && tag.type != TagEnd.TYPE) {
				if((getTimer() - time) > TIMEOUT) {
					enterFrameProvider.addEventListener(Event.ENTER_FRAME, parseTagsAsyncHandler);
					return;
				}
			}
			parseTagsFinalize();
			if(eof) {
				dispatchEvent(new SWFErrorEvent(SWFErrorEvent.ERROR, SWFErrorEvent.REASON_EOF));
			} else {
				dispatchEvent(new SWFProgressEvent(SWFProgressEvent.PROGRESS, _tmpData.position, _tmpData.length));
				dispatchEvent(new SWFProgressEvent(SWFProgressEvent.COMPLETE, _tmpData.position, _tmpData.length));
			}
		}
		
		protected function parseTagsInit(data:SWFData, version:uint):void {
			tags.length = 0;
			frames.length = 0;
			layers.length = 0;
			_dictionary = new Dictionary();
			currentFrame = new Frame();
			frameLabels = new Dictionary();
			hasSoundStream = false;
			_tmpData = data;
			_tmpVersion = version;
		}
		
		protected function parseTag(data:SWFData, async:Boolean = false):ITag {
			var pos:uint = data.position;
			// Bail out if eof
			eof = (pos >= data.length);
			if(eof) {
				trace("WARNING: end of file encountered, no end tag.");
				return null;
			}
			var tagRaw:SWFRawTag = data.readRawTag();
			var tagHeader:SWFRecordHeader = tagRaw.header;
			var tag:ITag = tagFactory.create(tagHeader.type);
			try {
				if(tag is SWFTimelineContainer) {
					var timelineContainer:SWFTimelineContainer = tag as SWFTimelineContainer;
					// Currently, the only SWFTimelineContainer (other than the SWF root
					// itself) is TagDefineSprite (MovieClips have their own timeline).
					// Inject the current tag factory there.
					timelineContainer.tagFactory = tagFactory;
					timelineContainer.rootTimelineContainer = this;
				}
				// Parse tag
				tag.parse(data, tagHeader.contentLength, _tmpVersion, async);
			} catch(e:Error) {
				// If we get here there was a problem parsing this particular tag.
				// Corrupted SWF, possible SWF exploit, or obfuscated SWF.
				// TODO: register errors and warnings
				trace("WARNING: parse error: " + e.message + ", Tag: " + tag.name + ", Index: " + tags.length);
				throw(e);
			}
			// Register tag
			tags.push(tag);
			tagsRaw.push(tagRaw);
			// Build dictionary and display list etc
			processTag(tag);
			// Adjust position (just in case the parser under- or overflows)
			if(data.position != pos + tagHeader.tagLength) {
				var index:uint = tags.length - 1;
				var excessBytes:int = data.position - (pos + tagHeader.tagLength);
				var eventType:String = (excessBytes < 0) ? SWFWarningEvent.UNDERFLOW : SWFWarningEvent.OVERFLOW;
				var eventData:Object = {
					pos: pos,
					bytes: (excessBytes < 0) ? -excessBytes : excessBytes
				};
				if(rootTimelineContainer == this) {
					trace("WARNING: excess bytes: " + excessBytes + ", " +
						"Tag: " + tag.name + ", " +
						"Index: " + index
					);
				} else {
					eventData.indexRoot = rootTimelineContainer.tags.length;
					trace("WARNING: excess bytes: " + excessBytes + ", " +
						"Tag: " + tag.name + ", " +
						"Index: " + index + ", " +
						"IndexRoot: " + eventData.indexRoot
					);
				}
				var event:SWFWarningEvent = new SWFWarningEvent(eventType, index, eventData, false, true);
				var cancelled:Boolean = !dispatchEvent(event);
				if (cancelled) {
					tag = null;
				}
				data.position = pos + tagHeader.tagLength;
			}
			return tag;
		}
		
		protected function parseTagsFinalize():void {
			if(soundStream && soundStream.data.length == 0) {
				_soundStream = null;
			}
			if(AUTOBUILD_LAYERS) {
				// TODO: This needs to go into processTags()
				buildLayers();
			}
		}

		public function publishTags(data:SWFData, version:uint):void {
			var tag:ITag;
			var tagRaw:SWFRawTag;
			for (var i:uint = 0; i < tags.length; i++) {
				tag = tags[i];
				tagRaw = (i < tagsRaw.length) ? tagsRaw[i] : null;
				publishTag(data, tag, tagRaw, version);
			}
		}

		public function publishTagsAsync(data:SWFData, version:uint):void {
			_tmpData = data;
			_tmpVersion = version;
			_tmpTagIterator = 0;
			enterFrameProvider.addEventListener(Event.ENTER_FRAME, publishTagsAsyncHandler);
		}

		protected function publishTagsAsyncHandler(event:Event):void {
			enterFrameProvider.removeEventListener(Event.ENTER_FRAME, publishTagsAsyncHandler);
			if(dispatchEvent(new SWFProgressEvent(SWFProgressEvent.PROGRESS, _tmpTagIterator, tags.length))) {
				publishTagsAsyncInternal();
			}
		}

		protected function publishTagsAsyncInternal():void {
			var tag:ITag;
			var tagRaw:SWFRawTag;
			var time:int = getTimer();
			do {
				tag = (_tmpTagIterator < tags.length) ? tags[_tmpTagIterator] : null;
				tagRaw = (_tmpTagIterator < tagsRaw.length) ? tagsRaw[_tmpTagIterator] : null;
				publishTag(_tmpData, tag, tagRaw, _tmpVersion);
				_tmpTagIterator++;
				if((getTimer() - time) > TIMEOUT) {
					enterFrameProvider.addEventListener(Event.ENTER_FRAME, publishTagsAsyncHandler);
					return;
				}
			}
			while (tag.type != TagEnd.TYPE);
			dispatchEvent(new SWFProgressEvent(SWFProgressEvent.PROGRESS, _tmpTagIterator, tags.length));
			dispatchEvent(new SWFProgressEvent(SWFProgressEvent.COMPLETE, _tmpTagIterator, tags.length));
		}

		public function publishTag(data:SWFData, tag:ITag, rawTag:SWFRawTag, version:uint):void {
			try {
				tag.publish(data, version);
			}
			catch (e:Error) {
				trace("WARNING: publish error: " + e.message + " (tag: " + tag.name + ")");
				if(rawTag) {
					rawTag.publish(data);
				} else {
					trace("FATAL: publish error: No raw tag fallback");
				}
			}
		}

		protected function processTag(tag:ITag):void {
			var currentTagIndex:uint = tags.length - 1;
			if(tag is IDefinitionTag) {
				processDefinitionTag(tag as IDefinitionTag, currentTagIndex);
				return;
			} else if(tag is IDisplayListTag) {
				processDisplayListTag(tag as IDisplayListTag, currentTagIndex);
				return;
			}
			switch(tag.type) {
				// Frame labels and scenes
				case TagFrameLabel.TYPE:
				case TagDefineSceneAndFrameLabelData.TYPE:
					processFrameLabelTag(tag, currentTagIndex);
					break;
				// Sound stream
				case TagSoundStreamHead.TYPE:
				case TagSoundStreamHead2.TYPE:
				case TagSoundStreamBlock.TYPE:
					if(EXTRACT_SOUND_STREAM) {
						processSoundStreamTag(tag, currentTagIndex);
					}
					break;
				// Background color
				case TagSetBackgroundColor.TYPE:
					processBackgroundColorTag(tag as TagSetBackgroundColor, currentTagIndex);
					break;
				// Global JPEG Table
				case TagJPEGTables.TYPE:
					processJPEGTablesTag(tag as TagJPEGTables, currentTagIndex);
					break;
			}
		}
		
		protected function processDefinitionTag(tag:IDefinitionTag, currentTagIndex:uint):void {
			if(tag.characterId > 0) {
				// Register definition tag in dictionary
				// key: character id
				// value: definition tag index
				dictionary[tag.characterId] = currentTagIndex;
				// Register character id in the current frame's character array
				currentFrame.characters.push(tag.characterId);
			}
		}

		protected function processDisplayListTag(tag:IDisplayListTag, currentTagIndex:uint):void {
			switch(tag.type) {
				case TagShowFrame.TYPE:
					currentFrame.tagIndexEnd = currentTagIndex;
					if(currentFrame.label == null && frameLabels[currentFrame.frameNumber]) {
						currentFrame.label = frameLabels[currentFrame.frameNumber];
					}
					frames.push(currentFrame);
					currentFrame = currentFrame.clone();
					currentFrame.frameNumber = frames.length;
					currentFrame.tagIndexStart = currentTagIndex + 1; 
					break;
				case TagPlaceObject.TYPE:
				case TagPlaceObject2.TYPE:
				case TagPlaceObject3.TYPE:
					currentFrame.placeObject(currentTagIndex, tag as TagPlaceObject);
					break;
				case TagRemoveObject.TYPE:
				case TagRemoveObject2.TYPE:
					currentFrame.removeObject(tag as TagRemoveObject);
					break;
			}
		}

		protected function processFrameLabelTag(tag:ITag, currentTagIndex:uint):void {
			switch(tag.type) {
				case TagDefineSceneAndFrameLabelData.TYPE:
					var tagSceneAndFrameLabelData:TagDefineSceneAndFrameLabelData = tag as TagDefineSceneAndFrameLabelData;
					var i:uint;
					for(i = 0; i < tagSceneAndFrameLabelData.frameLabels.length; i++) {
						var frameLabel:SWFFrameLabel = tagSceneAndFrameLabelData.frameLabels[i] as SWFFrameLabel;
						frameLabels[frameLabel.frameNumber] = frameLabel.name;
					}
					for(i = 0; i < tagSceneAndFrameLabelData.scenes.length; i++) {
						var scene:SWFScene = tagSceneAndFrameLabelData.scenes[i] as SWFScene;
						scenes.push(new Scene(scene.offset, scene.name));
					}
					break;
				case TagFrameLabel.TYPE:
					var tagFrameLabel:TagFrameLabel = tag as TagFrameLabel;
					currentFrame.label = tagFrameLabel.frameName;
					break;
			}
		}
		
		protected function processSoundStreamTag(tag:ITag, currentTagIndex:uint):void {
			switch(tag.type) {
				case TagSoundStreamHead.TYPE:
				case TagSoundStreamHead2.TYPE:
					var tagSoundStreamHead:TagSoundStreamHead = tag as TagSoundStreamHead;
					_soundStream = new SoundStream();
					soundStream.compression = tagSoundStreamHead.streamSoundCompression;
					soundStream.rate = tagSoundStreamHead.streamSoundRate;
					soundStream.size = tagSoundStreamHead.streamSoundSize;
					soundStream.type = tagSoundStreamHead.streamSoundType;
					soundStream.numFrames = 0;
					soundStream.numSamples = 0;
					break;
				case TagSoundStreamBlock.TYPE:
					if(soundStream != null) {
						if(!hasSoundStream) {
							hasSoundStream = true;
							soundStream.startFrame = currentFrame.frameNumber;
						}
						var tagSoundStreamBlock:TagSoundStreamBlock = tag as TagSoundStreamBlock;
						var soundData:ByteArray = tagSoundStreamBlock.soundData;
						soundData.endian = Endian.LITTLE_ENDIAN;
						soundData.position = 0;
						switch(soundStream.compression) {
							case SoundCompression.ADPCM: // ADPCM
								// TODO
								break;
							case SoundCompression.MP3: // MP3
								var numSamples:uint = soundData.readUnsignedShort();
								var seekSamples:int = soundData.readShort();
								if(numSamples > 0) {
									soundStream.numSamples += numSamples;
									soundStream.data.writeBytes(soundData, 4);
								}
								break;
						}
						soundStream.numFrames++;
					}
					break;
			}
		}

		protected function processBackgroundColorTag(tag:TagSetBackgroundColor, currentTagIndex:uint):void {
			backgroundColor = tag.color;
		}

		protected function processJPEGTablesTag(tag:TagJPEGTables, currentTagIndex:uint):void {
			jpegTablesTag = tag;
		}
		
		public function buildLayers():void {
			var i:uint;
			var depth:String;
			var depthInt:uint;
			var depths:Dictionary = new Dictionary();
			var depthsAvailable:Array = [];
			
			for(i = 0; i < frames.length; i++) {
				var frame:Frame = frames[i];
				for(depth in frame.objects) {
					depthInt = parseInt(depth);
					if(depthsAvailable.indexOf(depthInt) > -1) {
						(depths[depth] as Array).push(frame.frameNumber);
					} else {
						depths[depth] = [frame.frameNumber];
						depthsAvailable.push(depthInt);
					}
				}
			}

			depthsAvailable.sort(Array.NUMERIC);

			for(i = 0; i < depthsAvailable.length; i++) {
				var layer:Layer = new Layer(depthsAvailable[i], frames.length);
				var frameIndices:Array = depths[depthsAvailable[i].toString()];
				var frameIndicesLen:uint = frameIndices.length;
				if(frameIndicesLen > 0) {
					var curStripType:uint = LayerStrip.TYPE_EMPTY;
					var startFrameIndex:uint = uint.MAX_VALUE;
					var endFrameIndex:uint = uint.MAX_VALUE;
					for(var j:uint = 0; j < frameIndicesLen; j++) {
						var curFrameIndex:uint = frameIndices[j];
						var curFrameObject:FrameObject = frames[curFrameIndex].objects[layer.depth] as FrameObject;
						if(curFrameObject.isKeyframe) {
							// a keyframe marks the start of a new strip: save current strip
							layer.appendStrip(curStripType, startFrameIndex, endFrameIndex);
							// set start of new strip
							startFrameIndex = curFrameIndex;
							// evaluate type of new strip (motion tween detection see below)
							curStripType = (getCharacter(curFrameObject.characterId) is TagDefineMorphShape) ? LayerStrip.TYPE_SHAPETWEEN : LayerStrip.TYPE_STATIC;
						} else if(curStripType == LayerStrip.TYPE_STATIC && curFrameObject.lastModifiedAtIndex > 0) {
							// if one of the matrices of an object in a static strip is
							// modified at least once, we are dealing with a motion tween:
							curStripType = LayerStrip.TYPE_MOTIONTWEEN;
						}
						// update the end of the strip
						endFrameIndex = curFrameIndex;
					}
					layer.appendStrip(curStripType, startFrameIndex, endFrameIndex);
				}
				_layers.push(layer);
			}

			for(i = 0; i < frames.length; i++) {
				var frameObjs:Dictionary = frames[i].objects;
				for(depth in frameObjs) {
					FrameObject(frameObjs[depth]).layer = depthsAvailable.indexOf(parseInt(depth));
				}
			}	
		}
		
		public function toString(indent:uint = 0, flags:uint = 0):String {
			var i:uint;
			var str:String = "";
			if (tags.length > 0) {
				str += "\n" + StringUtils.repeat(indent + 2) + "Tags:";
				for (i = 0; i < tags.length; i++) {
					str += "\n" + tags[i].toString(indent + 4);
				}
			}
			if ((flags & SWF.TOSTRING_FLAG_TIMELINE_STRUCTURE) != 0) {
				if (scenes.length > 0) {
					str += "\n" + StringUtils.repeat(indent + 2) + "Scenes:";
					for (i = 0; i < scenes.length; i++) {
						str += "\n" + scenes[i].toString(indent + 4);
					}
				}
				if (frames.length > 0) {
					str += "\n" + StringUtils.repeat(indent + 2) + "Frames:";
					for (i = 0; i < frames.length; i++) {
						str += "\n" + frames[i].toString(indent + 4);
					}
				}
				if (layers.length > 0) {
					str += "\n" + StringUtils.repeat(indent + 2) + "Layers:";
					for (i = 0; i < layers.length; i++) {
						str += "\n" + StringUtils.repeat(indent + 4) + 
							"[" + i + "] " + layers[i].toString(indent + 4);
					}
				}
			}
			return str;
		}
	}
}
