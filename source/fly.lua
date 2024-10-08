-- Importing
require("source.brain")
require("source.functions")

-- Create fly function
function newFly(maxSteps)
    -- Dynamic atributtes
    local screenHeight = love.graphics.getHeight()
    local screenWidth = love.graphics.getWidth()

    local fly = {
        -- Default atributtes
        position = {
            x = screenWidth * 0.5,
            y = screenHeight * 0.8
        },
        vel = {
            x = 0,
            y = 0
        },
        acc = {
            x = 0,
            y = 0
        },
        fitness = 0,

        brain = newBrain(maxSteps),

        -- Boolean atributtes
        dead = false,
        reachedFood = false,
        isBest = false,

        -- Functions
        show = function(self)
            if self.isBest then
                love.graphics.setColor(0, 1, 0) -- Green
                love.graphics.circle("fill", self.position.x, self.position.y, 8)
            else
                love.graphics.setColor(1, 1, 1) -- Black
                love.graphics.circle("fill", self.position.x, self.position.y, 4)
            end
        end,

        move = function(self)
            if self.brain.step < #self.brain.directions then
                self.acc.x = self.brain.directions[self.brain.step].x
                self.acc.y = self.brain.directions[self.brain.step].y
                self.brain.step = self.brain.step + 1
            else
                self.dead = true
            end

            self.vel.x = self.vel.x + self.acc.x
            self.vel.y = self.vel.y + self.acc.y

            local maxSpeed = 1
            if self.vel.x > maxSpeed then self.vel.x = maxSpeed end
            if self.vel.y > maxSpeed then self.vel.y = maxSpeed end

            self.position.x = self.position.x + self.vel.x
            self.position.y = self.position.y + self.vel.y
        end,

        update = function(self, food)
            if not self.dead and not self.reachedFood then
                self:move()

                if self.position.x < 2 or self.position.y < 2 or self.position.x > love.graphics.getWidth() - 2 or self.position.y > love.graphics.getHeight() - 2 then
                    self.dead = true
                elseif dist(self.position.x, self.position.y, food.x, food.y) < 5 then
                    self.reachedFood = true
                elseif self.position.x < 600 and self.position.y < 310 and self.position.x > 0 and self.position.y > 300 then
                    self.dead = true
                end
            end
        end,

        calculateFitness = function(self, food)
            if self.reachedFood then
                self.fitness = 1.0 / 16.0 + 10000.0 / (self.brain.step * self.brain.step)
            else
                local distanceToFood = dist(self.position.x, self.position.y, food.x, food.y)
                self.fitness = 1.0 / (distanceToFood * distanceToFood)
            end
        end,

        clone = function()
            local babyFly = newFly(maxSteps)
            babyFly.brain = self.brain:clone()
            return babyFly
        end
    }

    -- Returning the object
    return fly
end

-- Returning the "new" function
return newFly