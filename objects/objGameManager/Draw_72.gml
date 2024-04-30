// Camera lerping
var _camera = camera_get_active();

cameraWidth = camera_get_view_width(_camera);
cameraHeight = camera_get_view_height(_camera);

cameraCurrentX = lerp(cameraCurrentX,cameraTargetX,1/cameraLerpTime);
cameraCurrentY = lerp(cameraCurrentY,cameraTargetY,1/cameraLerpTime);

camera_set_view_pos(_camera,cameraCurrentX,cameraCurrentY);