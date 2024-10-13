--Anime Selection Tool
--author: shynez.com
--version 1.1.0
fileIn "SHYNEZ_TR_Util.ms"

if Util_IsScriptUIOpen "SHYNEZ_TR_SelectionTool" do (
    return print "The script instance is already open.\nTry Execute This Script: \nUtil_DeleteScriptUIOpenState \"SHYNEZ_TR_SelectionTool\"\n"
)
Util_AddScriptUIOpenState "SHYNEZ_TR_SelectionTool"


ICON_BUTTON_DIR = (getDir #ui_ln) + @"Resources\Dark\Icons\Main\"
ICON_BUTTON_FREEZE = ICON_BUTTON_DIR + "Freeze Selection - 000000E0_00000000 - 24.png"
ICON_BUTTON_HIDE = ICON_BUTTON_DIR + "Hide Geometry Toggle - 00009CFE_00000000 - 24.png"
ICON_BUTTON_RENDER = ICON_BUTTON_DIR + "Render Selected - RenderSelected_Render - 24.png"
ICON_BUTTON_OPENLAYER = ICON_BUTTON_DIR + "Set Current Layer to Selection's Layer - LayerSet_Layers - 32.png"
ICON_BUTTON_ROOT = ICON_BUTTON_DIR + "Root - 00009C44_71D4627A - 32.png"

lastSelection
-- func
AstGetHeadTop
AstCreateTextHeadTop
AstSetLayer
AstHierarchyFreeze
AstHierarchyHidden
AstHierarchyRenderable

-- rollout
SHYNEZ_TR_SelectionTool
SHYNEZ_TR_SelectionToolMenu

fn ObjectSelectionCallback = (
	if classof $ == text or classof $ == SplineShape then (
		if SHYNEZ_TR_SelectionToolMenu.open and $ != lastSelection do
            DestroyDialog SHYNEZ_TR_SelectionToolMenu
		
		findResult = if (findString (getUserPropBuffer $) "AST_Text_flag") == undefined then 0 else findString (getUserPropBuffer $) "AST_Text_flag"
		if findResult > 0 do (
			dialog_size = [180, 180]
			dialog_pos = [mouse.screenpos.x - dialog_size.x/2 - 3, mouse.screenpos.y - dialog_size.y/2 - 3]
			createDialog SHYNEZ_TR_SelectionToolMenu width:dialog_size.x height:dialog_size.y pos:dialog_pos style:#(#style_sysmenu)
		)
	) else (
		DestroyDialog SHYNEZ_TR_SelectionToolMenu
	)
	if selection.count == 1 do (
		findResult = if (findString (getUserPropBuffer $) "AST_Text_flag") == undefined then 0 else findString (getUserPropBuffer $) "AST_Text_flag"
		if findResult > 0 do lastSelection = $
	)
)

rollout SHYNEZ_TR_SelectionTool "Ani Sel Tool 1.1.1" (
	edittext stObjName "名称: "
	edittext stObjLayer "层: "
	button stObjCreate "创建" width:134 height:36
	
	on stObjCreate pressed do (
		if selection.count != 1 then (
			messagebox "请选择根节点"
		) else if stObjName.text == "" then (
			messagebox "他谁啊？"
		) else (
			selObjPos = if classof $ == Biped_Object then (biped.getTransform $ #pos) else $.pos
			headTop = AstGetHeadTop()
			theText = AstCreateTextHeadTop stObjName.text [selObjPos.x, selObjPos.y, headTop + 30]
			AstSetLayer stObjLayer.text theText
		)
    )

    label author "Author" align:#left across:2
	hyperLink authorLink "shynez语出" color:red hoverColor:red visitedColor:green address:"http://shynez.com/" align:#right

    on SHYNEZ_TR_SelectionTool close do (
        Util_DeleteScriptUIOpenState "SHYNEZ_TR_SelectionTool"
    )
)
createDialog SHYNEZ_TR_SelectionTool height:110

callbacks.removeScripts id:#AnimeSelectionTool
callbacks.addScript #selectionSetChanged "ObjectSelectionCallback()" id:#AnimeSelectionTool
callbacks.addScript #selectionSetChanged "ObjectSelectionCallback()" id:#AnimeSelectionTool

rollout SHYNEZ_TR_SelectionToolMenu "Ani Sel Tool" (
	checkbutton freezeButton "冻结" toolTip: "冻结" images:#(ICON_BUTTON_FREEZE,undefined,1,1,1,1,1,true) width:60 height:60 pos:[0,0] across:3
	checkbutton visibleButton "显示" toolTip: "显示" images:#(ICON_BUTTON_HIDE,undefined,1,1,1,1,1,true) width:60 height:60 pos:[61,0]
	checkbutton renderableButton "可渲染" toolTip: "可渲染" images:#(ICON_BUTTON_RENDER,undefined,1,1,1,1,1,true) width:60 height:60 pos:[121,0]
	button selRootButton "根" toolTip: "根" images:#(ICON_BUTTON_ROOT,undefined,1,1,1,1,1,true) width:60 height:60 pos:[61,61]
	
	on freezeButton changed state do (
		AstHierarchyFreeze state
	)
	on freezeButton rightclick do (
		DestroyDialog SHYNEZ_TR_SelectionToolMenu
	)
	on visibleButton changed state do (
		AstHierarchyHidden state
	)
	on visibleButton rightclick do (
		DestroyDialog SHYNEZ_TR_SelectionToolMenu
	)
	on renderableButton changed state do (
		AstHierarchyRenderable state
	)
	on renderableButton rightclick do (
		DestroyDialog SHYNEZ_TR_SelectionToolMenu
	)
	on selRootButton pressed do (
		select $.parent
	)
	on selRootButton rightclick do (
		DestroyDialog SHYNEZ_TR_SelectionToolMenu
	)
	on openLayerButton pressed do (
		DestroyDialog SHYNEZ_TR_SelectionToolMenu
		macros.run "Layers" "LayerManager"
	)
	on openLayerButton rightclick do (
		DestroyDialog SHYNEZ_TR_SelectionToolMenu
	)
	
	on SHYNEZ_TR_SelectionToolMenu open do (
		freezeButton.state = $.parent.isFrozen
		visibleButton.state = not $.parent.isHidden
		renderableButton.state = $.parent.renderable
	)
)

fn AstCreateTextHeadTop textName textPos = (
	findIt = false
	theText
	for obj in $.children do (
		findResult = if (findString (getUserPropBuffer obj) "AST_Text_flag") == undefined then 0 else findString (getUserPropBuffer obj) "AST_Text_flag"
		if findResult > 0 do findIt = true
	)
	if not findIt do (
		theText = Text name:("AST_text__"+textName) text:textName size:30 pos:textPos font:"微软雅黑" wireColor:green
		setUserPropBuffer theText "AST_Text_flag\r\n"
		rotate theText (angleaxis 90 [1,0,0])
		theText.parent = $
	)
	theText
)

fn AstSetLayer layerName theText = (
	userSelect = $
	if layerName != undefined and layerName != "" and theText != undefined do (
		LayerManager.newLayerFromName layerName
		
		layerPos = [theText.pos.x, theText.pos.y, theText.pos.z + 34]
		layerText = Text name:("AST_text__"+layerName) text:layerName size:20 pos:layerPos wireColor:green
		rotate layerText (angleaxis 90 [1,0,0])
		layerText.parent = theText
		
		if selection.count == 1 do (
			theLayer = LayerManager.getLayerFromName layerName
			select (execute ("$" + $.name + "/...*"))
			for obj in selection where obj != theText do (
				theLayer.addNode obj
			)
		)
	)
)

fn AstGetHeadTop = (
	userSelect = $
	boundingTop = 0
	w = (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])
	
	if selection.count == 1 do (
		select (execute ("$" + $.name + "/...*"))
		if selection.count > 0 then (
			for obj in selection do (
				boundingTop = amax boundingTop (nodeGetBoundingBox obj w)[2].z
			)
		) else (
			boundingTop = (nodeGetBoundingBox $ w)[2].z
		)
	)
	select userSelect
	boundingTop
)

fn AstHierarchyFreeze btnState = (
	userSelect = $
	if selection.count == 1 do (
		select (execute ("$" + $.parent.name + "/...*"))
		if btnState then freeze $ else unfreeze $
	)
	unfreeze userSelect
	if userSelect.children.count > 0 do unfreeze userSelect.children[1]
	select userSelect.parent
)

fn AstHierarchyHidden btnState = (
	userSelect = $
	if selection.count == 1 do (
		select (execute ("$" + $.parent.name + "/...*"))
		if btnState then unhide $ else hide $
	)
	unhide userSelect
	if userSelect.children.count > 0 do unhide userSelect.children[1]
	select userSelect.parent
)

fn AstHierarchyRenderable btnState = (
	userSelect = $
	if selection.count == 1 do (
		select (execute ("$" + $.parent.name + "/...*"))
		for obj in selection where userSelect != obj do (
			obj.renderable = btnState
		)
	)
	if userSelect.children.count > 0 do userSelect.children[1].renderable = true
	select userSelect.parent
)
