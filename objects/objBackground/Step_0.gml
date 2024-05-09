if(rotate)
{
	image_angle++	
	if(image_angle==180)
	{
		rotate=false
		stars=true
	}
}
if (image_angle>=360) image_angle = 0;

if(stars)
{
	
	layer_sequence_create("Assets",960,540,sqButtonFadeIn);
	print("working")

		stars=false
}

if(layer_sequence_is_finished(sqButtonFadeIn))
{
	instance_create_layer(,960,540,"Instances",objStartButton)
	layer_sequence_destroy(sqButtonFadeIn)
	print("Destroying")
}