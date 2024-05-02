// Object Wall (X axis) collisions
function getWallCollision(offset = 1) {
    if (!canCollideX) return false; // If the subject can't collide with wall objects (X axis), return false
    return collision_point(x+offset,y,objWall,false,false); // Check for a collision with the wall object using the offset, and return the result
}

function executeWallCollision() {
    if (getWallCollision(xSpeed)) { // If there is a collision with a wall object
        while (abs(xSpeed) > 0.1) { // While the speed is greater than 0.1
            xSpeed*=0.5; // Reduce the speed by half
            if (!getWallCollision(xSpeed)) x += xSpeed; // If there is no collision with the wall object, move the subject by the speed
        }
        xSpeed = 0; // Set the speed to 0
    }
    x += xSpeed; // Move the subject along the X axis by the processed speed
}

// Object Ground (Y axis) collisions
function getGroundCollision(offset = 1) {
    if (!canCollideY) return false; // If the subject can't collide with ground objects (Y axis), return false
    return collision_point(x,y+offset,objWall,false,false); // Check for a collision with the ground object using the offset, and return the result
}

// Imagine executeWallCollision(), but using getGroundCollision() instead
function executeGroundCollision() {
    if(getGroundCollision(ySpeed)) {
        while(abs(ySpeed) > 0.1) {
            ySpeed *= 0.5;
            if (!getGroundCollision(ySpeed)) y += ySpeed;
        }
        ySpeed = 0;
    }
    y += ySpeed; // Move the subject along the Y axis by the speed
}
