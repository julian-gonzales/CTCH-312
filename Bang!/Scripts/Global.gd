extends Node

var rangeScores: Array[int] = [1,2,3,4,5,6,7,8,9,0]

var dartScores_701: Array[HighScore] = []
var dartScores_501: Array[HighScore] = []
var dartScores_301: Array[HighScore] = []
var dartScores_around_world: Array[HighScore] = []

enum DART_MODE {SEVEN_HUNDRED_ONE = 1, FIVE_HUNDRED_ONE = 2, THREE_HUNDRED_ONE = 3, AROUND_THE_WORLD = 4}

func find_and_replace_shooter_score(score: int):
	if rangeScores.min() < score:
		var minIndex = rangeScores.find(rangeScores.min())
		rangeScores.remove_at(minIndex)
		rangeScores.append(score)

func initialize_dart_scores():
	for i in range(10):
		var temp_701 = HighScore.new(i + 13, false)
		dartScores_701.append(temp_701)
		
		var temp_501 = HighScore.new(i + 10, false)
		dartScores_501.append(temp_501)
		
		var temp_301 = HighScore.new(i + 7, false)
		dartScores_301.append(temp_301)
		
		var temp_around_world = HighScore.new(i + 21, false)
		dartScores_around_world.append(temp_around_world)

func get_high_score_max(high_scores: Array[HighScore]) -> HighScore:
	var max = high_scores[0]
	for high_score in high_scores:
		if(high_score.score > max.score):
			max = high_score
	return max

func find_and_replace_dart_score(num_darts: int, mode: int):
	#Avoid invalid modes
	if(mode < 1 || mode > 4):
		return
	
	var new_high_score = HighScore.new(num_darts, true)
	
	if(mode == DART_MODE.SEVEN_HUNDRED_ONE && get_high_score_max(dartScores_701).score > new_high_score.score):
		var minIndex = dartScores_701.find(get_high_score_max(dartScores_701))
		dartScores_701.remove_at(minIndex)
		dartScores_701.append(new_high_score)
	
	elif(mode == DART_MODE.FIVE_HUNDRED_ONE && get_high_score_max(dartScores_501).score > new_high_score.score):
		var minIndex = dartScores_501.find(get_high_score_max(dartScores_501))
		dartScores_501.remove_at(minIndex)
		dartScores_501.append(new_high_score)
	
	elif(mode == DART_MODE.THREE_HUNDRED_ONE && get_high_score_max(dartScores_301).score > new_high_score.score):
		var minIndex = dartScores_301.find(get_high_score_max(dartScores_301))
		dartScores_301.remove_at(minIndex)
		dartScores_301.append(new_high_score)
	
	elif(mode == DART_MODE.AROUND_THE_WORLD && get_high_score_max(dartScores_around_world).score > new_high_score.score):
		var minIndex = dartScores_around_world.find(get_high_score_max(dartScores_around_world))
		dartScores_around_world.remove_at(minIndex)
		dartScores_around_world.append(new_high_score)
