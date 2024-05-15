var currentCollisions = ds_list_create();

instance_place_list(x,y, collidable, currentCollisions, false);

for (var i = 0; i < ds_list_size(currentCollisions); ++i) {
	var _char = ds_list_find_value(currentCollisions,i);
	if array_contains(collidedWith,_char) return;
	if _char.currentState != CharacterStates.BLOCK {
		with _char {
			if (currentState != CharacterStates.DEAD) {
				TakeDamage(other.collisionDamage);
		
			if (other.shouldStun) GetStunned(other.stunDir,other.stunHeight);
			}
		}
	}
	if !(_char.currentState == CharacterStates.BLOCK) {
		array_push(collidedWith,_char);
	} else {
		if array_contains(blockedBy,_char) return;
		_char.staminaLevel = max(staminaLevel-staminaBlockCost,0);
		if (_char.object_index == objEnemyTraining) _char.aiFitness += 40;
		array_push(blockedBy,_char);
		var indicator = instance_create_layer(x,y-512,"Instances",objDamageIndicator);
		indicator.depth = -100;
		indicator.valueShown = "BLOCKED";
		indicator.valueColor = make_color_rgb(80,160,220);
	}
}

ds_list_destroy(currentCollisions);