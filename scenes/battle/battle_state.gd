class_name BattleState
extends RefCounted

var deck: Array[StuffDie]
var hand: Array[StuffDie]
var discard: Array[StuffDie]

var mana: int
var rerolls: int

var roll_results: Array[RollResult]

class RollResult:
	var die: StuffDie
	var face: int
