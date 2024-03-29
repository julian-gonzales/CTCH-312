extends Node

var rangeScores: Array[int] = [1,2,3,4,5,6,7,8,9,0]
var dartScores: Array[int] = [1,2,3,4,5,6,7,8,9,0]

func find_and_replace_shooter_score(score: int):
	if rangeScores.min() < score:
		var minIndex = rangeScores.find(rangeScores.min())
		rangeScores.remove_at(minIndex)
		rangeScores.append(score)

func find_and_replace_dart_scores(score: int):
		if dartScores.min() < score:
			var minIndex = dartScores.find(dartScores.min())
			dartScores.remove_at(minIndex)
			dartScores.append(score)
