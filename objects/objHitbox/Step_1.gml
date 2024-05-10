var currentCollisions = ds_list_create();

instance_place_list(x,y, collidable, currentCollisions, false);

for (var i = 0; i < ds_list_size(currentCollisions); ++i) {
	var _char = ds_list_find_value(currentCollisions,i);
	if array_contains(collidedWith,_char) return;
	with _char {
		if (currentState != CharacterStates.DEAD) TakeDamage(other.collisionDamage);
	}
	if (instance_exists(_char) and !(_char.currentState == CharacterStates.BLOCK)) array_push(collidedWith,_char);
}