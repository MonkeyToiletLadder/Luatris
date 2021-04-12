-- maybe just use love2d callbacks for keypressed and key released

local input = {}

input.manager = {}
input.manager.__index = input.manager

input.key = {}

input.key.constants = {
    "a",
    "b",
    "c",
    "d",
    "e",
    "f",
    "g",
    "h",
    "i",
    "j",
    "k",
    "l",
    "m",
    "n",
    "o",
    "p",
    "q",
    "r",
    "s",
    "t",
    "u",
    "v",
    "w",
    "x",
    "y",
    "z",
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "space",
    "!",
    "\"",
    "#",
    "$",
    "&",
    "'",
    "(",
    ")",
    "*",
    "+",
    ",",
    "-",
    ".",
    "/",
    ":",
    ";",
    "<",
    "=",
    ">",
    "?",
    "@",
    "[",
    "\\",
    "]",
    "^",
    "_",
    "`",
    "kp0",
    "kp1",
    "kp2",
    "kp3",
    "kp4",
    "kp5",
    "kp6",
    "kp7",
    "kp8",
    "kp9",
    "kp.",
    "kp,",
    "kp/",
    "kp*",
    "kp-",
    "kp+",
    "kpenter",
    "kp=",
    "up",
    "down",
    "right",
    "left",
    "home",
    "end",
    "pageup",
    "pagedown",
    "insert",
    "backspace",
    "tab",
    "clear",
    "return",
    "delete",
    "f1",
    "f2",
    "f3",
    "f4",
    "f5",
    "f6",
    "f7",
    "f8",
    "f9",
    "f10",
    "f11",
    "f12",
    "f13",
    "f14",
    "f15",
    "f16",
    "f17",
    "f18",
    "numlock",
    "capslock",
    "scrolllock",
    "rshift",
    "lshift",
    "rctrl",
    "lctrl",
    "ralt",
    "lalt",
    "rgui",
    "lgui",
    "mode",
    "www",
    "mail",
    "calculator",
    "computer",
    "appsearch",
    "apphome",
    "appback",
    "appforward",
    "apprefresh",
    "appbookmarks",
    "pause",
    "escape",
    "help",
    "printscreen",
    "sysreq",
    "menu",
    "application",
    "power",
    "currencyunit",
    "undo",
}

input.key.state = {}
input.key.state.__index = input.key.state

function input.key.state.new()
    local _keystate = {}

    _keystate.prev = false
    _keystate.curr = false
    _keystate.start_time = 0
    _keystate.delta_time = 0

    return setmetatable(_keystate, input.key.state)
end

function input.manager.new()
    local _manager = {}

    _manager.keys = {}

    for i, key in ipairs(input.key.constants) do
        _manager.keys[key] = input.key.state.new()
    end

    return setmetatable(_manager, input.manager)
end
function input.manager:update()
    for i, key in ipairs(input.key.constants) do
        self.keys[key].prev = self.keys[key].curr
        if love.keyboard.isDown(key) then
            if not self.keys[key].curr then
                self.keys[key].start_time = love.timer.getTime()
                self.keys[key].curr = true
            end
        else
            self.keys[key].curr = false
            self.keys[key].start_time = nil
            self.keys[key].delta_time = 0
        end
        if self.keys[key].start_time then
            self.keys[key].delta_time = love.timer.getTime() - self.keys[key].start_time
        end
    end
end
-- currently pressed or held down
function input.manager:is_down(key, time, mod)
    time = time or 0
    local active = self.keys[key].curr and self.keys[key].delta_time >= time
    if active then
        self:reset_start_time(key, mod)
        return true
    else
        return false
    end
end
function input.manager:reset_start_time(key, mod)
    mod = mod or 0
    self.keys[key].start_time = love.timer.getTime() + mod
end
-- just pressed
function input.manager:is_keypressed(key)
    return not self.keys[key].prev and self.keys[key].curr
end
-- just released
function input.manager:is_keyreleased(key)
    return self.keys[key].prev and not self.keys[key].curr
end

return input
