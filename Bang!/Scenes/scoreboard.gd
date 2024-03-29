extends Node3D

var currRangeScores: Array[int] = []
var currDartsScore: Array[int] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	_on_dart_game_update_high_score(Global.DART_MODE.SEVEN_HUNDRED_ONE)
	_on_dart_game_update_high_score(Global.DART_MODE.FIVE_HUNDRED_ONE)
	_on_dart_game_update_high_score(Global.DART_MODE.THREE_HUNDRED_ONE)
	_on_dart_game_update_high_score(Global.DART_MODE.AROUND_THE_WORLD)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_shooter_box_update_high_score():
	var sortedScores = Global.rangeScores
	sortedScores.sort()
	sortedScores.reverse()
	$RangeScores/Score1.text = str(sortedScores[0])
	$RangeScores/Score2.text = str(sortedScores[1])
	$RangeScores/Score3.text = str(sortedScores[2])
	$RangeScores/Score4.text = str(sortedScores[3])
	$RangeScores/Score5.text = str(sortedScores[4])
	$RangeScores/Score6.text = str(sortedScores[5])
	$RangeScores/Score7.text = str(sortedScores[6])
	$RangeScores/Score8.text = str(sortedScores[7])
	$RangeScores/Score9.text = str(sortedScores[8])
	$RangeScores/Score10.text = str(sortedScores[9])

func sort_high_scores_ascending(a: HighScore, b: HighScore):
	if a.score < b.score:
		return true
	return false

func _on_dart_game_update_high_score(mode: int):
	#Stop invalid input
	if(mode < 1 || mode > 4):
		return
	
	var sortedScores: Array[HighScore] = []
	var parent_node = ""
	if(mode==Global.DART_MODE.SEVEN_HUNDRED_ONE):
		sortedScores = Global.dartScores_701
		sortedScores.sort_custom(sort_high_scores_ascending)
		parent_node = $DartsScores/Darts701
	elif(mode==Global.DART_MODE.FIVE_HUNDRED_ONE):
		sortedScores = Global.dartScores_501
		sortedScores.sort_custom(sort_high_scores_ascending)
		parent_node = $DartsScores/Darts501
	elif(mode==Global.DART_MODE.THREE_HUNDRED_ONE):
		sortedScores = Global.dartScores_301
		sortedScores.sort_custom(sort_high_scores_ascending)
		parent_node = $DartsScores/Darts301
	elif(mode==Global.DART_MODE.AROUND_THE_WORLD):
		sortedScores = Global.dartScores_around_world
		sortedScores.sort_custom(sort_high_scores_ascending)
		parent_node = $DartsScores/DartsAroundWorld
	
	for i in range(10):
		parent_node.get_node("Score" + str(i+1)).text = str(sortedScores[i].score)
		if(sortedScores[i].is_player == true):
			parent_node.get_node("Score" + str(i+1)).modulate = Color.GREEN
		else:
			parent_node.get_node("Score" + str(i+1)).modulate = Color.WHITE
