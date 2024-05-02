// Camera
cameraCurrentX = 0;
cameraCurrentY = 0;
cameraCurrentW = 1920;
cameraCurrentH = 1080;
cameraTargetX = cameraCurrentX;
cameraTargetY = cameraCurrentY;
cameraTargetW = cameraCurrentW;
cameraTargetH = cameraCurrentH;
cameraMinW = 1280;
cameraMinH = 720;

cameraAspRatio = cameraCurrentH/cameraCurrentW;

cameraLerpTime = 5;

focusedCharacters = [];
focusPadding = 256;
floorPadding = 64;


// Gameplay
gameGravity = 0.6;