extends ColorsTextureLoader
class_name OperatorColorsTextureLoader

func initLoader(path:String,frames:int,params:Dictionary) -> OperatorTextureLoader:
	return OperatorTextureLoader.new(path,params.capitalised,frames)

func colorSelect(color:Colors.ColorDef) -> bool: return color.keyTexture
func colorFrames(color:Colors.ColorDef) -> int: return color.keyTextureFrames
