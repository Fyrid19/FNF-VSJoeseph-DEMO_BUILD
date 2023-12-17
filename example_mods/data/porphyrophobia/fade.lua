function onCreate()
	--debugPrint('fucker')
	makeLuaSprite('i fucking hate', image, -500, -500)
	makeGraphic('i fucking hate', 3000, 3000, '000000')
	setProperty('i fucking hate.alpha', 0)
	addLuaSprite('i fucking hate', true)
end

function onStepHit()
	if curStep == 1792 then
		doTweenAlpha('shits', 'i fucking hate', 1, 4, 'linear')
	end
end