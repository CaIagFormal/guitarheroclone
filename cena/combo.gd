class_name Combo
extends Label

@export var combo: int = 0

var targetcol: Color = Color(255,255,255)

func setcombo(cmb: int):
	combo = cmb
	
	if combo < 20:
		targetcol = Color(255,255,255,255)
	elif combo < 50:
		targetcol = Color(255,0,0,255)
	elif combo < 100:
		targetcol = Color(0,255,0,255)
	else:
		targetcol = Color(0,0,255,255)
	
func toarray(col: Color):
	return [col.r,col.g,col.b,col.a]
func _process(delta: float) -> void:
	if label_settings.font_color == targetcol:
		return
	var fc: Color = toarray(label_settings.font_color)
	label_settings.font_color = targetcol
	
	#label_settings.font_color = Color(int(fc.r+(combo.r-fc.r)*0.2*delta),int(fc.g+(combo.g-fc.g)*0.2*delta),int(fc.b+(combo.b-fc.b)*0.2*delta))
