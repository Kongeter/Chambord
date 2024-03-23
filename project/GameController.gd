extends Node
var numOfFigures  = 7;
var numOfBigFigures  = 0;
var numOfPlayers = 3;

# Called when the node enters the scene tree for the first time.

var scores = [];
var freeFigures = [];
var cards = [];

func _ready():
	scores.resize(numOfPlayers);
	scores.fill(0);
	freeFigures.resize(numOfPlayers);
	freeFigures.fill(numOfFigures);
	
	var tempc = Card.new(1,1,3,3,0,0)
	Scorer.getStreetOrCityConnection(tempc, 3, true)
	
	#Closes Game instantly
	await get_tree().create_timer(0.1).timeout
	get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
