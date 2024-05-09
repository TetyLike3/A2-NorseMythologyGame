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
	instance_create_layer(960,540,"Stars",psStars)
	stars=false
}