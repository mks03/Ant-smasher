require("gameEngine")
local roamingBomb = require("roamingBomb")
local scene = storyboard.newScene()
storyboard.purgeOnSceneChange = true

group = nil

local menu
local bg
local getBgIndex
local scoreBar
local scoreText
local maxScoreText
local getMaxScore
local pauseButton
local pauseBar
local pauseOverlay
local pauseGroup
--global
lives = {}
numLives = 3
score = 0
gameOver = false

local onKeyEvent
local scoreFront
local adGroup = display.newGroup()
local pauseGame
local showTutorial
local tutorialGroup
local gameStartTime
local gameEndTime


local function getAds()
    local ads={}
    local iconAds = {"spelltheword","dressupfree","balloonpop"}
    local bannerAds = {"fruitshoot"}
    for i=1,1 do
        local pos = math.random(#bannerAds)
        table.insert( ads, i, bannerAds[pos] )
        table.remove( bannerAds, pos )
    end
    for i=1,2 do
        local pos = math.random(#iconAds)
        table.insert( ads, i+1, iconAds[pos] )
        table.remove( iconAds, pos )
    end
    return ads
end

local function adClick(event)
    local target = event.target
    
    system.openURL("market://details?id=com.gaakapps."..target.url )
end



local function showAds(target)
    if adGroup == nil then
        adGroup = display.newGroup()
    end
    target:removeEventListener("tap",pauseGame)
    local group = target.parent
    local image = getAds()
    group:insert(adGroup)
    adGroup.anchorChildren = true
    adGroup.x = display.contentCenterX
    adGroup.y = display.contentCenterY
    local bannerAd = display.newImage(adGroup,"ads/".. image[1] ..".jpg",display.contentCenterX, display.contentCenterY/2 + 50)
    bannerAd.url = image[1]
    local iconAdOne = display.newImage(adGroup,"ads/".. image[2] ..".png",display.contentCenterX-200, (3*display.contentCenterY)/2)
    iconAdOne.url = image[2]
    local iconAdTwo = display.newImage(adGroup,"ads/".. image[3] ..".png",display.contentCenterX+200, (3*display.contentCenterY)/2)
    iconAdTwo.url = image[3]
    bannerAd:addEventListener("tap", adClick)
    iconAdOne:addEventListener("tap", adClick)
    iconAdTwo:addEventListener("tap", adClick)
        transition.from(adGroup, {time = 200,xScale =0.01,yScale=0.01,onComplete = function() 
    target:addEventListener("tap",pauseGame) end })
end

local function hideAds(target)
    target:removeEventListener("tap",pauseGame)
        transition.to(adGroup, {time = 200,xScale =0.01,yScale=0.01,onComplete = function() 
            adGroup:removeSelf()
            adGroup=nil
            target:addEventListener("tap",pauseGame)
    end })
end
function pauseGame( event )
    local target = event.target
    if target.pauseState == true then
        GameEngine.pause(pauseGroup)
        target.pauseState = false
        Analytics.logEvent("game_pause")
        --        showAds(target)
    else
        GameEngine.resume(pauseGroup)
        target.pauseState = true
        --        hideAds(target)
    end
end
    
function showTutorial(grp)
    grp:insert(tutorialGroup)
    local tutorialShadow = display.newRect(tutorialGroup, CENTER_X, CENTER_Y, TOTAL_WIDTH, TOTAL_HEIGHT)
    tutorialShadow:setFillColor(0, 0, 0)
    tutorialShadow.alpha = 0.6
    local tutorial = display.newImage(tutorialGroup, "images/tutorial.png",CENTER_X,CENTER_Y)
    local tutorialClose = display.newImage(tutorialGroup, "images/no.png",tutorial.contentBounds.xMax,tutorial.contentBounds.yMin )
    
    local tutorialHide = function(event) 
        GameEngine.new(group,roamingBomb) 
        tutorialGroup.alpha = 0
        optionIce:store( "tutorial_shown", true )
        optionIce:save()
    end
    
    
    tutorial:addEventListener("tap", tutorialHide)
    tutorialClose:addEventListener("tap", tutorialHide)
end


    function scoreFront(event)
        scoreText.text = score
        if(score > getMaxScore ) then
            maxScoreText.text = score
        end
        scoreBar:toFront()
        scoreText:toFront()
        maxScoreText:toFront()
        if numLives > 0 then
            for i=1,numLives do 
                lives[i]:toFront()
            end
        else
            transition.cancel()
            gameOver = true
            storyboard.gotoScene( "restartView", "fade", 600 )
        end	
        
	
    end
    
    function onKeyEvent(event)
	
        local phase = event.phase
        
        if event.phase=="down" and event.keyName=="back" then
            
            transition.cancel()
            gameOver = true
            storyboard.gotoScene( "menu", "fade", 600 )
            return true
        end
        return false
    end

function scene:createScene(event)
    group = self.view
    pauseGroup = display.newGroup()
    tutorialGroup = display.newGroup()
    numLives = 3
    score = 0
    gameOver = false
    getBgIndex = optionIce:retrieve("background")
    getMaxScore = maxScore:retrieve("max")
    bg = display.newImage(group,"images/bg_game" .. getBgIndex .. ".jpg",display.contentCenterX,display.contentCenterY)
    scoreBar = display.newImage(group,"images/score-bar.png",display.contentCenterX, bufferHeight + 140)
    scoreText = display.newText(group,score , 140 , bufferHeight + 65 ,"Base 02",30)
    for i=1,numLives do 
        lives[i] = display.newImage(group,"images/life.png",display.contentCenterX - 90 + (50 * i) , bufferHeight + 65)
    end
    maxScoreText = display.newText(group,getMaxScore , display.viewableContentWidth - 135 , bufferHeight + 65 ,"Base 02",30)
    pauseButton = display.newImage(group,"images/pause.png",display.contentCenterX, bufferHeight + 140)
    pauseButton.pauseState = true
    pauseBar = display.newImage(pauseGroup,"images/pause_bar.png",-display.contentCenterX, display.contentCenterY)
    pauseOverlay = display.newRect(pauseGroup, -CENTER_X, CENTER_Y, TOTAL_WIDTH, TOTAL_HEIGHT)
    pauseOverlay:setFillColor(0, 0, 0)
    pauseOverlay.alpha = 0.6
    group:insert(pauseGroup)
    
    if optionIce:retrieve("tutorial_shown") == true then
        GameEngine.new(group,roamingBomb)
    else
        showTutorial(group)
    end
    
    --Analytics
    gameStartTime = os.time(os.date( "*t" ))
    
end


function scene:enterScene(event)
    -- ads.show( "banner", { x=0, y=1160,interval=50,appId="ca-app-pub-2883837174861368/5479620739"} )
    myAds.show()
    Runtime:addEventListener( "enterFrame", scoreFront)
    Runtime:addEventListener( "key", onKeyEvent )
    pauseButton:addEventListener("tap",pauseGame)
    print("enter")
end


function scene:exitScene(event)
    myAds.hide()
    roamingBomb.destroyAll()
    Runtime:removeEventListener( "enterFrame", scoreFront)
    Runtime:removeEventListener( "key", onKeyEvent )
    transition.cancel()
    gameEndTime = os.time(os.date('*t'))
    Analytics.logEvent("game_play_time",{time = gameEndTime - gameStartTime , score = score})
end

function scene:destroyScene(event)
    print("destroy")
end



scene:addEventListener( "createScene", scene )

scene:addEventListener( "enterScene", scene )

scene:addEventListener( "exitScene", scene )

scene:addEventListener( "destroyScene", scene )


return scene