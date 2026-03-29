extends PanelContainer
class_name Mouseover

const LOCK_TYPES = ["", "Blank ", "Blast ", "All ", "Exact ", "Starry "]

func describe(object:GameObject, pos:Vector2, screenBottomRight:Vector2) -> void:
	if !object:
		visible = false
		return
	visible = true
	var string:String = ""
	match object.get_script():
		KeyBulk:
			match object.type:
				KeyBulk.TYPE.EXACT: string += "Exact "
				KeyBulk.TYPE.STAR: string += "Unstar " if object.un else "Star "
				KeyBulk.TYPE.ROTOR:
					if M.eq(object.count, M.nONE): string += "Signflip "
					elif M.eq(object.count, M.I): string += "Rotor (i) "
					elif M.eq(object.count, M.nI): string += "Rotor (-i) "
				KeyBulk.TYPE.CURSE: string += "Uncurse " if object.un else "Curse "
			string += Game.COLOR_NAMES[object.color] + " Key"
			if object.type in [KeyBulk.TYPE.NORMAL, KeyBulk.TYPE.EXACT]:
				string += "\nAmount: " + M.str(object.count)
			if object.color == Game.COLOR.GLITCH: string += "\nMimic: " + Game.COLOR_NAMES[object.glitchMimic]
			elif object.color == Game.COLOR.ERROR: string += "\nMimic: " + Game.COLOR_NAMES[object.errorMimic]
			if object.glistening:
				string += "\n- Effects -\nGlistening!"
		Door:
			if object.type == Door.TYPE.SIMPLE:
				string += LOCK_TYPES[object.locks[0].type] + Game.COLOR_NAMES[object.colorSpend] + " Door"
				var additional:String = lockAdditionalInfo(object.locks[0], object)
				if additional: string += " (Lock " + additional + ")"
				string += "\nCost: " + lockCost(object.locks[0])
				if object.locks[0].color != object.colorSpend: string += " " + Game.COLOR_NAMES[object.locks[0].color]
			else:
				if object.type == Door.TYPE.COMBO:
					string += Game.COLOR_NAMES[object.colorSpend]
					string += " Lockless Door" if len(object.locks) == 0 else " Combo Door"
				else: string += "Empty Gate" if len(object.locks) == 0 else "Gate"
				for lock in object.locks:
					string += "\nLock: " + LOCK_TYPES[lock.type] + Game.COLOR_NAMES[lock.color] + ", Cost: " + lockCost(lock)
					var additional:String = lockAdditionalInfo(lock, object)
					if additional: string += " (" + additional + ")"
			if object.hasInitialColor(Game.COLOR.GLITCH): string += "\nMimic: " + Game.COLOR_NAMES[object.glitchMimic]
			elif object.hasInitialColor(Game.COLOR.ERROR): string += "\nMimic: " + Game.COLOR_NAMES[object.errorMimic]
			string += effects(object)
			
		RemoteLock:
			string += LOCK_TYPES[object.type] + Game.COLOR_NAMES[object.color] + " Remote Lock\n"
			string += ("S" if object.satisfied else "Uns") + "atisfied, Cost: " + lockCost(object)
			if object.type == Lock.TYPE.GLISTENING: string += " Glistening"
			if object.type in [Lock.TYPE.BLAST, Lock.TYPE.ALL]: string += " (" + M.str(object.cost) + ")"
			if object.armament: string += " (Armament)"
			if object.color == Game.COLOR.GLITCH: string += "\nMimic: " + Game.COLOR_NAMES[object.glitchMimic]
			elif object.color == Game.COLOR.ERROR: string += "\nMimic: " + Game.COLOR_NAMES[object.errorMimic]
			string += effects(object)
		_:
			visible = false
			return
	%text.text = string
	size = Vector2.ZERO
	position = pos
	if position.x + size.x > screenBottomRight.x: position.x -= size.x
	if position.y + size.y > screenBottomRight.y: position.y -= size.y

func lockAdditionalInfo(lock:Lock, door:Door) -> String:
	var additional:Array[String] = []
	if lock.armament: additional.append("Armament")
	if door.colorSpend in [Game.COLOR.GLITCH, Game.COLOR.ERROR] and lock.getColor(Lock.COLOR_STEP.EFFECTIVE) != door.getColor(Door.COLOR_STEP.EFFECTIVE): additional.append("Mimic: " + Game.COLOR_NAMES[lock.getColor(Lock.COLOR_STEP.EFFECTIVE)])
	if additional: return ", ".join(additional)
	else: return ""

func lockCost(lock:GameComponent) -> String:
	var string:String = ""
	if lock.negated: string += "Not "
	match lock.type:
		Lock.TYPE.NORMAL: string += M.str(lock.count) if M.ex(lock.count) else "None"
		Lock.TYPE.BLANK: string += "None"
		Lock.TYPE.BLAST, Lock.TYPE.ALL:
			string += "["
			var numerator:PackedInt64Array = lock.count
			var divideThrough:bool = !M.isComplex(lock.denominator) and (!M.isComplex(numerator) or !lock.isPartial)
			if divideThrough: numerator = M.divide(numerator,M.saxis(lock.denominator))
			if M.neq(numerator, M.ONE): string += M.str(numerator)
			string += "All" if lock.type == Lock.TYPE.BLAST else "ALL"
			if lock.type == Lock.TYPE.BLAST and divideThrough: string += (" -" if M.negative(M.sign(lock.denominator)) else " +") + ("i" if M.isNonzeroImag(lock.denominator) else "")
			if lock.isPartial:
				if divideThrough: string += "/" + M.str(M.divide(lock.denominator, M.saxis(lock.denominator)))
				else: string += " / " + M.str(lock.denominator)
			string += "]"
		Lock.TYPE.EXACT:
			string += "Exactly " + M.str(lock.count)
			if lock.zeroI: string += "i"
		Lock.TYPE.GLISTENING:
			string += M.str(lock.count) + " Glistening"
	return string

func effects(object:GameObject) -> String:
	var string:String = ""
	if object.cursed:
		if object.curseColor == Game.COLOR.BROWN: string += "\nCursed!"
		else:
			string += "\nCursed " + Game.COLOR_NAMES[object.curseColor] + "!"
			if object.curseColor == Game.COLOR.GLITCH: string += " (Mimic: " + Game.COLOR_NAMES[object.curseMimic] + ")"
			elif object.curseColor == Game.COLOR.ERROR: string += " (Mimic: " + Game.COLOR_NAMES[object.curseMimic] + ")"
	if object.gameFrozen: string += "\nFrozen! (1xRed)"
	if object.gameCrumbled: string += "\nEroded! (5xGreen)"
	if object.gamePainted: string += "\nPainted! (3xBlue)"
	if object is Door:
		match object.starred:
			Door.STAR_STATE.STARRED_UNLOCKED: string += "\nStarred! (Unlocked)"
			Door.STAR_STATE.STARRED_LOCKED: string += "\nStarred! (Locked)"
		if object.starred != Door.STAR_STATE.UNSTARRED:
			string += "\n    Spends " + M.str(object.starredSpendKey)
			if M.ex(object.starredSpendGlisten):
				string += "(" + M.str(object.starredSpendGlisten) + ")"
			if object.hasArmamentLocks(): string += " (+ Armament locks)"
			string += " " + Game.COLOR_NAMES[object.starredColor] + ")"
	if string: string = "\n- Effects -" + string
	return string
