collidedWith = [];

var collisionsOnSpawn = ds_list_create();
collision_rectangle_list(x-(sprite_width/2),y-(sprite_height/2),x+(sprite_width/2),y+(sprite_height/2),objDummy,true,true,collisionsOnSpawn,false);

for (var i = 0; i < ds_list_size(collisionsOnSpawn); ++i) {
	var _char = ds_list_find_value(collisionsOnSpawn,i);
	with _char TakeDamage(5);
	if instance_exists(_char) array_push(collidedWith,_char.id);
}