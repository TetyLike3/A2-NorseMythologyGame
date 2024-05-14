y -= yIncrement;
yIncrement = lerp(startIncrement,0,timeLeft-lifetime);
timeLeft--;

if (timeLeft <= 0) instance_destroy();