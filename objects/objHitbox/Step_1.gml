var collisionsOnSpawn = ds_list_create();
collision_rectangle_list(x-(sprite_width/2),y-(sprite_height/2),x+(sprite_width/2),y+(sprite_height/2),objEnemy,true,true,collisionsOnSpawn,false);

for (var i = 0; i < ds_list_size(collisionsOnSpawn); ++i) {
	var _char = ds_list_find_value(collisionsOnSpawn,i);
	if array_contains(collidedWith,_char) return;
	with _char TakeDamage(other.collisionDamage);
	if instance_exists(_char) array_push(collidedWith,_char);
}