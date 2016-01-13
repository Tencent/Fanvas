package com.codeazur.as3swf.factories
{
	import com.codeazur.as3swf.SWF;
	import com.codeazur.as3swf.tags.*;
	import com.codeazur.as3swf.tags.etc.*;
	
	public class SWFTagFactory implements ISWFTagFactory
	{
		public function create(type:uint):ITag
		{
			switch(type) {
				/*   0 */ case TagEnd.TYPE: return createTagEnd();
				/*   1 */ case TagShowFrame.TYPE: return createTagShowFrame();
				/*   2 */ case TagDefineShape.TYPE: return createTagDefineShape();
				/*   4 */ case TagPlaceObject.TYPE: return createTagPlaceObject();
				/*   5 */ case TagRemoveObject.TYPE: return createTagRemoveObject();
				/*   6 */ case TagDefineBits.TYPE: return createTagDefineBits();
				/*   7 */ case TagDefineButton.TYPE: return createTagDefineButton();
				/*   8 */ case TagJPEGTables.TYPE: return createTagJPEGTables();
				/*   9 */ case TagSetBackgroundColor.TYPE: return createTagSetBackgroundColor();
				/*  10 */ case TagDefineFont.TYPE: return createTagDefineFont();
				/*  11 */ case TagDefineText.TYPE: return createTagDefineText();
				/*  12 */ case TagDoAction.TYPE: return createTagDoAction();
				/*  13 */ case TagDefineFontInfo.TYPE: return createTagDefineFontInfo();
				/*  14 */ case TagDefineSound.TYPE: return createTagDefineSound();
				/*  15 */ case TagStartSound.TYPE: return createTagStartSound();
				/*  17 */ case TagDefineButtonSound.TYPE: return createTagDefineButtonSound();
				/*  18 */ case TagSoundStreamHead.TYPE: return createTagSoundStreamHead();
				/*  19 */ case TagSoundStreamBlock.TYPE: return createTagSoundStreamBlock();
				/*  20 */ case TagDefineBitsLossless.TYPE: return createTagDefineBitsLossless();
				/*  21 */ case TagDefineBitsJPEG2.TYPE: return createTagDefineBitsJPEG2();
				/*  22 */ case TagDefineShape2.TYPE: return createTagDefineShape2();
				/*  23 */ case TagDefineButtonCxform.TYPE: return createTagDefineButtonCxform();
				/*  24 */ case TagProtect.TYPE: return createTagProtect();
				/*  26 */ case TagPlaceObject2.TYPE: return createTagPlaceObject2();
				/*  28 */ case TagRemoveObject2.TYPE: return createTagRemoveObject2();
				/*  32 */ case TagDefineShape3.TYPE: return createTagDefineShape3();
				/*  33 */ case TagDefineText2.TYPE: return createTagDefineText2();
				/*  34 */ case TagDefineButton2.TYPE: return createTagDefineButton2();
				/*  35 */ case TagDefineBitsJPEG3.TYPE: return createTagDefineBitsJPEG3();
				/*  36 */ case TagDefineBitsLossless2.TYPE: return createTagDefineBitsLossless2();
				/*  37 */ case TagDefineEditText.TYPE: return createTagDefineEditText();
				/*  39 */ case TagDefineSprite.TYPE: return createTagDefineSprite();
				/*  40 */ case TagNameCharacter.TYPE: return createTagNameCharacter();
				/*  41 */ case TagProductInfo.TYPE: return createTagProductInfo();
				/*  43 */ case TagFrameLabel.TYPE: return createTagFrameLabel();
				/*  45 */ case TagSoundStreamHead2.TYPE: return createTagSoundStreamHead2();
				/*  46 */ case TagDefineMorphShape.TYPE: return createTagDefineMorphShape();
				/*  48 */ case TagDefineFont2.TYPE: return createTagDefineFont2();
				/*  56 */ case TagExportAssets.TYPE: return createTagExportAssets();
				/*  57 */ case TagImportAssets.TYPE: return createTagImportAssets();
				/*  58 */ case TagEnableDebugger.TYPE: return createTagEnableDebugger();
				/*  59 */ case TagDoInitAction.TYPE: return createTagDoInitAction();
				/*  60 */ case TagDefineVideoStream.TYPE: return createTagDefineVideoStream();
				/*  61 */ case TagVideoFrame.TYPE: return createTagVideoFrame();
				/*  62 */ case TagDefineFontInfo2.TYPE: return createTagDefineFontInfo2();
				/*  63 */ case TagDebugID.TYPE: return createTagDebugID();
				/*  64 */ case TagEnableDebugger2.TYPE: return createTagEnableDebugger2();
				/*  65 */ case TagScriptLimits.TYPE: return createTagScriptLimits();
				/*  66 */ case TagSetTabIndex.TYPE: return createTagSetTabIndex();
				/*  69 */ case TagFileAttributes.TYPE: return createTagFileAttributes();
				/*  70 */ case TagPlaceObject3.TYPE: return createTagPlaceObject3();
				/*  71 */ case TagImportAssets2.TYPE: return createTagImportAssets2();
				/*  72 */ case TagDoABCDeprecated.TYPE: return createTagDoABCDeprecated();
				/*  73 */ case TagDefineFontAlignZones.TYPE: return createTagDefineFontAlignZones();
				/*  74 */ case TagCSMTextSettings.TYPE: return createTagCSMTextSettings();
				/*  75 */ case TagDefineFont3.TYPE: return createTagDefineFont3();
				/*  76 */ case TagSymbolClass.TYPE: return createTagSymbolClass();
				/*  77 */ case TagMetadata.TYPE: return createTagMetadata();
				/*  78 */ case TagDefineScalingGrid.TYPE: return createTagDefineScalingGrid();
				/*  82 */ case TagDoABC.TYPE: return createTagDoABC();
				/*  83 */ case TagDefineShape4.TYPE: return createTagDefineShape4();
				/*  84 */ case TagDefineMorphShape2.TYPE: return createTagDefineMorphShape2();
				/*  86 */ case TagDefineSceneAndFrameLabelData.TYPE: return createTagDefineSceneAndFrameLabelData();
				/*  87 */ case TagDefineBinaryData.TYPE: return createTagDefineBinaryData();
				/*  88 */ case TagDefineFontName.TYPE: return createTagDefineFontName();
				/*  89 */ case TagStartSound2.TYPE: return createTagStartSound2();
				/*  90 */ case TagDefineBitsJPEG4.TYPE: return createTagDefineBitsJPEG4();
				/*  91 */ case TagDefineFont4.TYPE: return createTagDefineFont4();

				/*  93 */ case TagEnableTelemetry.TYPE: return createTagEnableTelemetry();
				/*  94 */ case TagPlaceObject4.TYPE: return createTagPlaceObject4();

				/* 253 */ case TagSWFEncryptActions.TYPE: return createTagSWFEncryptActions();
				/* 255 */ case TagSWFEncryptSignature.TYPE: return createTagSWFEncryptSignature();

				default: return createTagUnknown(type);
			}
		}
		
		protected function createTagEnd():ITag { return new TagEnd(); }
		protected function createTagShowFrame():ITag { return new TagShowFrame(); }
		protected function createTagDefineShape():ITag { return new TagDefineShape(); }
		protected function createTagPlaceObject():ITag { return new TagPlaceObject(); }
		protected function createTagRemoveObject():ITag { return new TagRemoveObject(); }
		protected function createTagDefineBits():ITag { return new TagDefineBits(); }
		protected function createTagDefineButton():ITag { return new TagDefineButton(); }
		protected function createTagJPEGTables():ITag { return new TagJPEGTables(); }
		protected function createTagSetBackgroundColor():ITag { return new TagSetBackgroundColor(); }
		protected function createTagDefineFont():ITag { return new TagDefineFont(); }
		protected function createTagDefineText():ITag { return new TagDefineText(); }
		protected function createTagDoAction():ITag { return new TagDoAction(); }
		protected function createTagDefineFontInfo():ITag { return new TagDefineFontInfo(); }
		protected function createTagDefineSound():ITag { return new TagDefineSound(); }
		protected function createTagStartSound():ITag { return new TagStartSound(); }
		protected function createTagDefineButtonSound():ITag { return new TagDefineButtonSound(); }
		protected function createTagSoundStreamHead():ITag { return new TagSoundStreamHead(); }
		protected function createTagSoundStreamBlock():ITag { return new TagSoundStreamBlock(); }
		protected function createTagDefineBitsLossless():ITag { return new TagDefineBitsLossless(); }
		protected function createTagDefineBitsJPEG2():ITag { return new TagDefineBitsJPEG2(); }
		protected function createTagDefineShape2():ITag { return new TagDefineShape2(); }
		protected function createTagDefineButtonCxform():ITag { return new TagDefineButtonCxform(); }
		protected function createTagProtect():ITag { return new TagProtect(); }
		protected function createTagPlaceObject2():ITag { return new TagPlaceObject2(); }
		protected function createTagRemoveObject2():ITag { return new TagRemoveObject2(); }
		protected function createTagDefineShape3():ITag { return new TagDefineShape3(); }
		protected function createTagDefineText2():ITag { return new TagDefineText2(); }
		protected function createTagDefineButton2():ITag { return new TagDefineButton2(); }
		protected function createTagDefineBitsJPEG3():ITag { return new TagDefineBitsJPEG3(); }
		protected function createTagDefineBitsLossless2():ITag { return new TagDefineBitsLossless2(); }
		protected function createTagDefineEditText():ITag { return new TagDefineEditText(); }
		protected function createTagDefineSprite():ITag { return new TagDefineSprite(); }
		protected function createTagNameCharacter():ITag { return new TagNameCharacter(); }
		protected function createTagProductInfo():ITag { return new TagProductInfo(); }
		protected function createTagFrameLabel():ITag { return new TagFrameLabel(); }
		protected function createTagSoundStreamHead2():ITag { return new TagSoundStreamHead2(); }
		protected function createTagDefineMorphShape():ITag { return new TagDefineMorphShape(); }
		protected function createTagDefineFont2():ITag { return new TagDefineFont2(); }
		protected function createTagExportAssets():ITag { return new TagExportAssets(); }
		protected function createTagImportAssets():ITag { return new TagImportAssets(); }
		protected function createTagEnableDebugger():ITag { return new TagEnableDebugger(); }
		protected function createTagDoInitAction():ITag { return new TagDoInitAction(); }
		protected function createTagDefineVideoStream():ITag { return new TagDefineVideoStream(); }
		protected function createTagVideoFrame():ITag { return new TagVideoFrame(); }
		protected function createTagDefineFontInfo2():ITag { return new TagDefineFontInfo2(); }
		protected function createTagDebugID():ITag { return new TagDebugID(); }
		protected function createTagEnableDebugger2():ITag { return new TagEnableDebugger2(); }
		protected function createTagScriptLimits():ITag { return new TagScriptLimits(); }
		protected function createTagSetTabIndex():ITag { return new TagSetTabIndex(); }
		protected function createTagFileAttributes():ITag { return new TagFileAttributes(); }
		protected function createTagPlaceObject3():ITag { return new TagPlaceObject3(); }
		protected function createTagImportAssets2():ITag { return new TagImportAssets2(); }
		protected function createTagDefineFontAlignZones():ITag { return new TagDefineFontAlignZones(); }
		protected function createTagCSMTextSettings():ITag { return new TagCSMTextSettings(); }
		protected function createTagDefineFont3():ITag { return new TagDefineFont3(); }
		protected function createTagSymbolClass():ITag { return new TagSymbolClass(); }
		protected function createTagMetadata():ITag { return new TagMetadata(); }
		protected function createTagDefineScalingGrid():ITag { return new TagDefineScalingGrid(); }
		protected function createTagDoABC():ITag { return new TagDoABC(); }
		protected function createTagDoABCDeprecated():ITag { return new TagDoABCDeprecated(); }
		protected function createTagDefineShape4():ITag { return new TagDefineShape4(); }
		protected function createTagDefineMorphShape2():ITag { return new TagDefineMorphShape2(); }
		protected function createTagDefineSceneAndFrameLabelData():ITag { return new TagDefineSceneAndFrameLabelData(); }
		protected function createTagDefineBinaryData():ITag { return new TagDefineBinaryData(); }
		protected function createTagDefineFontName():ITag { return new TagDefineFontName(); }
		protected function createTagStartSound2():ITag { return new TagStartSound2(); }
		protected function createTagDefineBitsJPEG4():ITag { return new TagDefineBitsJPEG4(); }
		protected function createTagDefineFont4():ITag { return new TagDefineFont4(); }
		protected function createTagEnableTelemetry():ITag { return new TagEnableTelemetry(); }
		protected function createTagPlaceObject4():ITag { return new TagPlaceObject4(); }
		
		protected function createTagSWFEncryptActions():ITag { return new TagSWFEncryptActions(); }
		protected function createTagSWFEncryptSignature():ITag { return new TagSWFEncryptSignature(); }

		protected function createTagUnknown(type:uint):ITag { return new TagUnknown(type); }
	}
}
