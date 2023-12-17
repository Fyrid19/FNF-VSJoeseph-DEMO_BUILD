function onCreate()
  thisIs = -1400;
  makeLuaSprite('joeseph_bg', 'joeseph_bg', -2700, -2300)
  scaleObject('joeseph_bg', 3.5, 3.5)
  addGlitchEffect('joeseph_bg',3,8)
  addLuaSprite('joeseph_bg', false)

  makeLuaSprite('cubes', 'cubes', -2300, thisIs)
  scaleObject('cubes', 2.2, 2.2)
  addGlitchEffect('cubes',1,20)
  addLuaSprite('cubes', false)

  doTweenY('cube tween part 1', 'cubes', thisIs+150, 2, 'cubeInOut')
end

function onTweenCompleted(tag)
	if tag == 'cube tween part 1' then
		doTweenY('cube tween part 2', 'cubes', thisIs, 2, 'quadInOut')
	end
	if tag == 'cube tween part 2' then
		doTweenY('cube tween part 1', 'cubes', thisIs+150, 2, 'quadInOut')
	end
end