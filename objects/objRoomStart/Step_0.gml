if(RoomStarted)
{
layer_sequence_create("Sequence",960,540,sqLoading);
RoomStarted=false
}

if(layer_sequence_is_finished(sqLoading))
{
	print("DONEZO")
	room_goto(rmMainMenu)
}
