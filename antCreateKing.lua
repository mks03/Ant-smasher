require("spriteAnim")
require("smash")
CreateKingAnt = {
    new = function(group,setSeq)
        local ant = SpriteAnim.new()
        local bee = {}
        local bee1 = {}
        local valY 
        local startY = 1280 + ant.contentWidth + 50
        ant.taps = 0
        --ant.rotation = 180
        local END_TIME = 8000 
        if (score < 500 )then
            END_TIME = END_TIME 
        elseif 	(score < 1000 )then
            END_TIME = END_TIME - 1000
        elseif 	(score < 1500 )then
            END_TIME = END_TIME - 2000
        elseif 	(score < 2000 )then
            END_TIME = END_TIME - 2500
        elseif 	(score < 3000 )then
            END_TIME = END_TIME - 3000
        elseif 	(score < 4000 )then
            END_TIME = END_TIME - 3500
        else
            END_TIME = END_TIME - 4000
        end
        ant:setSequence(setSeq)
        ant:play()
        ant.y = startY
        ant.x = math.random(bufferWidth+150,570-bufferWidth)
        group:insert(ant)
        ant:addEventListener( "sprite", SpriteAnim.spriteListener )
        for i=-1,1 do
            if i ~= 0 then
                bee[i] = SpriteAnim.new2()
                bee[i]:setSequence("bee")
                bee[i]:play()
                bee[i].x = ant.x + (ant.contentWidth + 50) * i
                bee[i].y = ant.y
                group:insert(bee[i])
                bee[i]:addEventListener( "sprite", SpriteAnim.spriteListener )
                bee[i]:addEventListener("touch",Smash.new)
                    transition.to(bee[i],{time = END_TIME , y = 0 , onComplete = function()
                        bee[i]:removeSelf(); 
                        bee[i] = nil
                end})
            end
        end
        
        for i=-1,1 do
            if i ~= 0 then
                local tempHeight = ant.y + (ant.contentHeight + 50) * i
                local deltaTime = (END_TIME * tempHeight)/startY
                bee1[i] = SpriteAnim.new2()
                bee1[i]:setSequence("bee")
                bee1[i]:play()
                bee1[i].x = ant.x
                bee1[i].y = tempHeight
                group:insert(bee1[i])
                bee1[i]:addEventListener( "sprite", SpriteAnim.spriteListener )
                bee1[i]:addEventListener("touch",Smash.new)
                    transition.to(bee1[i],{time = deltaTime   , y = 0 , onComplete = function()
                        bee1[i]:removeSelf(); 
                        bee1[i] = nil
                end})
            end
        end
            transition.to(ant,{time = END_TIME , y = 0 , onComplete = function()
                SpriteAnim.endLife(ant); 
                ant:removeSelf(); 
                ant = nil
        end})
        
        
        ant:addEventListener("touch",Smash.new)
    end
    
    
}