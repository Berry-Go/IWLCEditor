extends VBoxContainer
class_name ProblemDisplay

var modId:StringName
var mod:Mods.Mod
var type:StringName
var findProblems:FindProblems
var showIndex:int = 0
var count:int:
	get(): return len(mod.problems[type].components)

func setup(_mod:StringName,_type:StringName, _findProblems:FindProblems) -> ProblemDisplay:
	modId = _mod
	mod = Mods.mods[modId]
	type = _type
	findProblems = _findProblems
	%nameLabel.text = mod.problems[type].name
	return self

func setTexts() -> void:
	if count == 1: %countLabel.text = "1 instance"
	else: %countLabel.text = str(count) + " instances"
	%showIndex.text = str(showIndex+1) + "/" + str(count)
	visible = count > 0

func showInstance(index:int) -> void:
	showIndex = index
	setTexts()
	var component:GameComponent = mod.problems[type].components[index]
	if component is GameObject:
		Game.editor.focusDialog.defocusComponent()
		Game.editor.focusDialog.focus(component,true)
	else: Game.editor.focusDialog.focusComponent(component)
	Game.editor.scrollIntoView(component)

func _showPressed():
	%shower.visible = true
	%show.visible = false
	if findProblems.shownDisplay: findProblems.shownDisplay.stopShowing()
	findProblems.shownDisplay = self
	showInstance(0)

func stopShowing() -> void:
	if findProblems.shownDisplay != self: return
	findProblems.shownDisplay = null
	%show.visible = true
	%shower.visible = false

func _showLeft(): showInstance(posmod(showIndex-1,count))
func _showRight(): showInstance(posmod(showIndex+1,count))

func newInstance() -> void: setTexts()

func removeInstance(index:int) -> void:
	if count == 0:
		visible = false
		findProblems.problemsLabel.text = "Problems found:" if mod.hasProblems() else "No problems here"
		return
	if showIndex > index: showIndex -= 1
	elif showIndex == count: showInstance(index-1)
	elif showIndex == index: showInstance(index)
	setTexts()
