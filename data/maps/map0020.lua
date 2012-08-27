local map = ...
-- Lyriann cave 1F

local tom_initial_x = 0
local tom_initial_y = 0

function map:on_started(destination_point)

  tom_initial_x, tom_initial_y = map:npc_get_position("tom")

  if has_finished_cavern() and not has_boomerang_of_tom() then
    tom:remove()
  end

  if map:get_game():get_boolean(38) then
    barrier:set_enabled(false)
    open_barrier_switch:set_activated(true)
  end

  for _, enemy in ipairs(map:get_entities("battle_1_enemy")) do
    function enemy:on_dead()
      if not map:has_entities("battle_1_enemy") and battle_1_barrier:is_enabled() then
        map:move_camera(352, 288, 250, function()
          sol.audio.play_sound("secret")
          battle_1_barrier:set_enabled(false)
        end)
      end
    end
  end

  for _, enemy in ipairs(map:get_entities("battle_2_enemy")) do
    function enemy:on_dead()
      if not map:has_entities("battle_2_enemy") and battle_2_barrier:is_enabled() then
        map:move_camera(344, 488, 250, function()
          sol.audio.play_sound("secret")
          battle_2_barrier:set_enabled(false)
        end)
      end
    end
  end
end

function open_barrier_switch:on_activated()
  map:move_camera(136, 304, 250, function()
    sol.audio.play_sound("secret")
    barrier:set_enabled(false)
    map:get_game():set_boolean(38, true)
  end)
end

function tom:on_interaction()

  if not has_seen_tom() then
    map:start_dialog("lyriann_cave.tom.first_time")
  elseif has_finished_cavern() then
    if has_boomerang_of_tom() then
      map:start_dialog("lyriann_cave.tom.cavern_finished")
    else
      map:start_dialog("lyriann_cave.tom.see_you_later")
    end
  elseif has_boomerang_of_tom() then
    map:start_dialog("lyriann_cave.tom.not_finished")
  else
    map:start_dialog("lyriann_cave.tom.not_first_time")
  end
end

function map:on_dialog_finished(message_id, answer)

  if message_id == "lyriann_cave.tom.first_time" or message_id == "lyriann_cave.tom.not_first_time" then
    map:get_game():set_boolean(47, true)
    if answer == 0 then
      map:start_dialog("lyriann_cave.tom.accept_help")
    end
  elseif message_id == "lyriann_cave.tom.accept_help" then
    map:get_hero():start_treasure("boomerang", 1, 41)
  elseif message_id == "lyriann_cave.tom.leaving" then
    sol.audio.play_sound("warp")
    map:get_hero():set_direction(1)
    sol.timer.start(1700, start_moving_tom)
  elseif message_id == "lyriann_cave.tom.not_finished" and answer == 1 then
    give_boomerang_back()
    map:start_dialog("lyriann_cave.tom.gave_boomerang_back")
  elseif message_id == "lyriann_cave.tom.cavern_finished"
    or message_id == "lyriann_cave.tom.leaving.cavern_not_finished"
    or message_id == "lyriann_cave.tom.leaving.cavern_finished" then

    give_boomerang_back()
    local x, y = map:npc_get_position("tom")
    if y ~= tom_initial_y then
      local m = sol.movement.create("path")
      m:set_path{2,2,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2}
      m:set_speed(48)
      tom:start_movement(m)
      tom_sprite:set_animation("walking")
    end
  end

end

function give_boomerang_back()
  map:get_game():get_item("boomerang"):set_variant(0)
  map:get_game():set_boolean(41, false)
end

function start_moving_tom()
  local m = sol.movement.create("path")
  m:set_path{0,0,0,0,6,6,6,6,6,6}
  m:set_speed(48)
  tom:set_position(88, 509)
  tom:start_movement(m)
  tom:get_sprite():set_animation("walking")
end

function tom:on_movement_finished()

  if has_boomerang_of_tom() then
    if has_finished_cavern() then
      map:start_dialog("lyriann_cave.tom.cavern_finished")
    else
      map:start_dialog("lyriann_cave.tom.leaving.cavern_not_finished")
    end
  else
    tom:set_position(tom_initial_x, tom_initial_y)
    tom:get_sprite():set_direction(3)
    map:get_hero():unfreeze()
  end
end

function leave_cavern_sensor:on_activated()

  if has_boomerang_of_tom() then
    map:get_hero():freeze()
    map:start_dialog("lyriann_cave.tom.leaving")
  end
end

function has_seen_tom()
  return map:get_game():get_boolean(47)
end

function has_boomerang_of_tom()
  return map:get_game():get_boolean(41)
end

function has_finished_cavern()
  -- the cavern is considered has finished if the player has found the heart container
  return map:get_game():get_boolean(37)
end

