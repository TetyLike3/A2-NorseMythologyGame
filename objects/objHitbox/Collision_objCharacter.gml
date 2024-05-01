if array_contains(collidedWith,other.id) return;
with other TakeDamage(5);
if instance_exists(other) array_push(collidedWith,other.id);