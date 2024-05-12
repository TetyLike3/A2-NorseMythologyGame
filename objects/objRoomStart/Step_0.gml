if(roomStarted)
{
	layer_sequence_create("Sequence",960,540,sqLoading);
	roomStarted=false
}

if(layer_sequence_is_finished(sqLoading))
{
	print("DONEZO")
	room_goto(rmMainMenu)
}
