
-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
	print("----------------------------------------")
	print("LUA ERROR: " .. tostring(msg) .. "\n")
	print(debug.traceback())
	print("----------------------------------------")
end

function main(scrollview)
	-- avoid memory leak
	collectgarbage("setpause", 100)
	collectgarbage("setstepmul", 5000)

	local cclog = function(...)
		print(string.format(...))
	end

	local function creatSprite()

		local sp = CCSprite:create("Icon.png");
		sp:setPosition(ccp(350,350));

		return sp
	end

	local layer=CCLayer:create()
	local sp=creatSprite()
	layer:addChild(sp)
	scrollview:pushLayer(layer)


local url = "www.baidu.com"
local request =CCHTTPRequest:createWithUrlLua(
 
function(event)
    local request = event.request
    print("state:"..request:getState().."  code:"..request:getResponseStatusCode())
    local parseStr =  request:getResponseString()
    print(parseStr)
end, 
url,
kCCHTTPRequestMethodGET)
request:start()


	--seq =CCSequence:create(move,move2,nil);
    --repeatForever =CCRepeatForever:create(seq);
    --sp:runAction(repeatForever);
	local moveBy = CCMoveBy:create(5, ccp(300,200));
	local  actionByBack = moveBy:reverse();
	sp:runAction(actionByBack);
		
	
end


