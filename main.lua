if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

push = require 'lib.push'

-- https://github.com/vrld/hump/blob/master/class.lua
Class = require 'lib.class'

Timer = require 'lib.knife.timer'
Event = require 'lib.knife.event'
Behavior = require 'lib.knife.behavior'
anim8 = require 'lib.anim8'

require 'globals'

Entity = require 'Entity'
require 'EntityManager'
require 'StateMachine'
require 'states.BaseState'
require 'states.TitleState'
require 'states.LevelStartState'
require 'states.PlayState'
require 'states.ExtraLifeState'
require 'states.HighScoreState'
require 'states.GameOverState'
require 'entities.Player'
require 'entities.Enemy'
require 'entities.Wall'
require 'entities.Flower'
require 'entities.Letter'
require 'entities.Skull'
require 'entities.Plant'
require 'entities.Turnstile'
require 'entities.PlayFieldScore'
require 'util.Util'
Clock = require 'util.Clock'
tilemap = require 'data.tilemap'
turnstiles = require 'data.turnstiles'

require 'data.defs'

-- physical screen dimensions
WINDOW_WIDTH = 768
WINDOW_HEIGHT = 960

-- WINDOW_WIDTH = 192
-- WINDOW_HEIGHT = 240

-- virtual resolution dimensions
VIRTUAL_WIDTH = 192
VIRTUAL_HEIGHT = 240

PLAY_MUSIC = true
PLAYER_SPEED = 70

-- Debug flags

SHOW_HITBOXES = false
SHOW_TILES = false

local paused = false

function love.load()
    -- initialize our nearest-neighbor filter
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- seed the RNG
    math.randomseed(os.time())

    -- app window title
    love.window.setTitle('Lady Bug')

    love.keyboard.keyPressed = {}

    -- initialize our nice-looking retro text fonts
    smallFont = love.graphics.newFont('assets/fonts/lady-bug.ttf', 7)
    mediumFont = love.graphics.newFont('assets/fonts/lady-bug.ttf', 8)
    largeFont = love.graphics.newFont('assets/fonts/lady-bug.ttf', 10)

    -- load up the graphics we'll be using throughout our states
    gTextures = {
        ['title'] = love.graphics.newImage('assets/graphics/title.png'),
        ['playfield'] = love.graphics.newImage('assets/graphics/playfield.png'),
        ['top'] = love.graphics.newImage('assets/graphics/topfield.png'),
        ['ladybug'] = love.graphics.newImage('assets/graphics/ladybug.png'),
        ['turnstile'] = love.graphics.newImage('assets/graphics/turnstile.png'),
        ['flower'] = love.graphics.newImage('assets/graphics/dot.png'),
        ['cucumber'] = love.graphics.newImage('assets/graphics/cucumber.png'),
        ['skull'] = love.graphics.newImage('assets/graphics/skull.png'),
        ['ghost'] = love.graphics.newImage('assets/graphics/ghost.png'),
        ['heart'] = love.graphics.newImage('assets/graphics/heart.png'),
        ['a'] = love.graphics.newImage('assets/letters/a.png'),
        ['c'] = love.graphics.newImage('assets/letters/c.png'),
        ['e'] = love.graphics.newImage('assets/letters/e.png'),
        ['i'] = love.graphics.newImage('assets/letters/i.png'),
        ['l'] = love.graphics.newImage('assets/letters/l.png'),
        ['p'] = love.graphics.newImage('assets/letters/p.png'),
        ['r'] = love.graphics.newImage('assets/letters/r.png'),
        ['s'] = love.graphics.newImage('assets/letters/s.png'),
        ['t'] = love.graphics.newImage('assets/letters/t.png'),
        ['x'] = love.graphics.newImage('assets/letters/x.png'),
    }

    -- initialize our table of sounds
    sounds = {
        ['turnstile'] = love.audio.newSource('assets/sounds/turnstile.wav', 'static'),
        ['eatdot'] = love.audio.newSource('assets/sounds/eatdot.wav', 'static'),
        ['eatitem'] = love.audio.newSource('assets/sounds/eatitem.wav', 'static'),
        ['enemylaunch'] = love.audio.newSource('assets/sounds/enemylaunch.wav', 'static'),
        ['stageclear'] = love.audio.newSource('assets/sounds/stageclear.wav', 'static'),
        ['playerdeath'] = love.audio.newSource('assets/sounds/playerdeath.wav', 'static'),
        ['die'] = love.audio.newSource('assets/sounds/die.wav', 'static'),
        ['veggieeaten'] = love.audio.newSource('assets/sounds/veggieeaten.wav', 'static'),
        ['music'] = love.audio.newSource('assets/music/8_Bit_Retro_Funk_David_Renda.mp3', 'static')
    }

    -- initialize our virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    -- initialize state machine with all state-returning functions
    gStateMachine = StateMachine {
        ['title'] = function() return TitleState() end,
        ['levelstart'] = function () return LevelStartState() end,
        ['play'] = function() return PlayState() end,
        ['extralife'] = function() return ExtraLifeState() end,
        ['highscore'] = function() return HighScoreState() end,
        ['gameover'] = function() return GameOverState() end,
    }

    gStateMachine:change('title')
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)

    if paused == false then
        gStateMachine:update(dt)
    end

    Timer.update(dt)

end

function love.textinput(text)
    gStateMachine:textinput(text)
end

function love.keypressed(key)
    love.keyboard.keyPressed[key] = true
end

function love.draw()
    push:start()

    gStateMachine:draw()

    if paused then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Paused', 0, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH, 'center')
    end

    push:finish()

    love.keyboard.keyPressed = {}
end
