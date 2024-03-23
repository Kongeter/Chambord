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
	
	var tempc = Card.new(10,10,3,0,0,0)
	#Scorer.getStreetOrCityConnection(tempc, 3, true)
	#DebugHelper.showDirection(1)
	DebugHelper.showCoord([Coord.new(1,1), Coord.new(2,3)],10,10)
	#print(Helper.functionFindFirstIndex([2,1], (func(c): return (c == 1))))
	#print(Coord.new(1,1).equals(1,1))
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass








func moveScorer(newCard):
	#wenn stadt: stadt flood von da aus
	#wenn straße: straßen flood von da aus
	#schauen ob im umkreis Klosten -> dann schauen ob somit fertig
	pass
	
func endOfGameScorer():
	#alle spielsteine:
	#Wiese:
	pass

func grassFlood(card, quadrant, alreadyChecked):
	#card.x 
	#card.y
	#quadrant 0-3 :0obenLinks dann 1obenRechts 2untenRechts 3untenLinks
	pass


func _grassNeighbor(x,y,quadrant):
	pass
