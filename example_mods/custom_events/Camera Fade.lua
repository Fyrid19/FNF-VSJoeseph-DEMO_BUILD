function onEvent(n,v1,v2)
	if flashingLights then
		if n == "Camera Fade" then
			cameraFade("game", "000000", v1, true)
		end
	end
end