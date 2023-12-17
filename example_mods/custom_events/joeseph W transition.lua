dadY = 0

function onEvent(n, v1, v2)
    if n == "joeseph W transition" then
        dadY = getProperty("dad.y")
        doTweenColor("teehee", "dad", "FFFFFF", 0.9, "quintIn")
        doTweenX("wow1", "dad.scale", 1.8, 0.9, "quintIn")
        doTweenY("wow2", "dad.scale", 1.8, 0.9, "quintIn")
        doTweenY("wow3", "dad", dadY - 500, 0.9, "quintIn")
        doTweenZoom("wowza", "camGame", 0.5, 0.9, "quintIn")
        --startTween("wow", "dad.scale", 3.5, 1, "quintIn")
    end
end

function onTweenCompleted(tag)
    if tag == "teehee" then
        --doTweenX("wow7", "dad.scale", 1, 0.01, "linear")
        --doTweenY("wow8", "dad.scale", 1, 0.01, "linear")
    end
end