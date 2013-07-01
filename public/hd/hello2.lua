
function main(scrollview)
	-- avoid memory leak
	collectgarbage("setpause", 100)
	collectgarbage("setstepmul", 5000)

	local cclog = function(...)
		print(string.format(...))
	end

	local function creatSprite()

		local sp = CCSprite:create("Icon@2x.png");
		sp:setPosition(ccp(350,350));

		return sp
	end

	local layer=CCLayer:create()
	local sp=creatSprite()
	layer:addChild(sp)
	scrollview:pushLayer(layer)

	local moveBy = CCMoveBy:create(5, ccp(300,200));
	local  actionByBack = moveBy:reverse();
	sp:runAction(actionByBack);
	CCMessageBox("eee","sss");

end

