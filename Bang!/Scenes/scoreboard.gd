extends Node3D

var currRangeScores: Array[int] = []
var currDartsScore: Array[int] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_darts_scores():
	var sortedScores = currDartsScore
	sortedScores.sort()
	sortedScores.reverse()
	$DartsScores/Score1.text = str(sortedScores[0])
	$DartsScores/Score2.text = str(sortedScores[1])
	$DartsScores/Score3.text = str(sortedScores[2])
	$DartsScores/Score4.text = str(sortedScores[3])
	$DartsScores/Score5.text = str(sortedScores[4])
	$DartsScores/Score6.text = str(sortedScores[5])
	$DartsScores/Score7.text = str(sortedScores[6])
	$DartsScores/Score8.text = str(sortedScores[7])
	$DartsScores/Score9.text = str(sortedScores[8])
	$DartsScores/Score10.text = str(sortedScores[9])


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
