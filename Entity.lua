Entity = Class {}

function Entity:init(x, y, state)
	self.x = x
    self.y = y
	self.state = state
	self.isDestroyed = false
end

function Entity:update(dt)
end

function Entity:draw()

	if self.hitbox and SHOW_HITBOXES then
		love.graphics.setColor(1, 1, 1)
		love.graphics.rectangle("line", self.hitbox.x1, self.hitbox.y1, self.hitbox.x2 - self.hitbox.x1, self.hitbox.y2 - self.hitbox.y1)
	end

end

function Entity:move(x, y)
	self.x = self.x + x
    self.y = self.y + y
	if self.hitbox then
		self.hitbox.x1 = self.hitbox.x1 + x
		self.hitbox.x2 = self.hitbox.x2 + x
		self.hitbox.y1 = self.hitbox.y1 + y
		self.hitbox.y2 = self.hitbox.y2 + y
	end
end

function Entity:isOnScreen()
	if self.position.x > 320 then
		return false
	elseif self.position.x < 0 then
		return false
	elseif self.position.y > 240 then
		return false
	elseif self.position.y < 0 then
		return false
	end

	return true
end

function Entity:destroy()
	self.isDestroyed = true
end

function Entity:collide(otherEntity)
	if self.hitbox and otherEntity.hitbox then
		return not (
			otherEntity.hitbox.x1 > self.hitbox.x2 or
			otherEntity.hitbox.x2 < self.hitbox.x1 or
			otherEntity.hitbox.y1 > self.hitbox.y2 or
			otherEntity.hitbox.y2 < self.hitbox.y1)
	else
		return false
	end
end

return Entity