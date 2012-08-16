local map = ...
-- Dungeon 3 4F

function map:on_started(destination_point_name)

  map:door_set_open("miniboss_door", true)
  map:door_set_open("boss_door", true)
  if destination_point_name == "from_5f_c"
      or map:get_game():get_boolean(903) then
    map:door_set_open("final_room_door", true)
  end
end

fighting_miniboss = false
fighting_boss = false

function map:on_hero_on_sensor(sensor_name)

  if sensor_name == "start_miniboss_sensor"
      and not map:get_game():get_boolean(901)
      and not fighting_miniboss then
    -- the miniboss is alive
    map:door_close("miniboss_door")
    map:hero_walk(666666, false, false)
  elseif sensor_name == "start_miniboss_sensor_2"
      and not map:get_game():get_boolean(901)
      and not fighting_miniboss then
    map:hero_freeze()
    sol.audio.stop_music()
    sol.timer.start(1000, miniboss_timer)
    fighting_miniboss = true
  elseif sensor_name == "start_boss_sensor"
      and not map:get_game():get_boolean(902)
      and not fighting_boss then
    map:hero_freeze()
    map:door_close("boss_door")
    sol.audio.stop_music()
    sol.timer.start(1000, start_boss)
  end
end

function miniboss_timer()

  sol.audio.play_music("boss")
  map:enemy_set_enabled("miniboss", true)
  map:tile_set_group_enabled("miniboss_prickles", true)
  map:hero_unfreeze()
end

function map:on_enemy_dead(enemy_name)

  if enemy_name == "miniboss" then
    sol.audio.play_music("dark_world_dungeon")
    map:door_open("miniboss_door")
    map:tile_set_group_enabled("miniboss_prickles", false)
  end
end

function start_boss()

  map:enemy_set_enabled("boss", true)
  map:dialog_start("dungeon_3.arbror_hello")
end

function map:on_dialog_finished(dialog_id)

  if dialog_id == "dungeon_3.arbror_hello" then
    map:hero_unfreeze()
    sol.audio.play_music("boss")
    fighting_boss = true
  end
end

function map:on_treasure_obtained(item_name, variant, savegame_variable)

  if item_name == "heart_container" then
    sol.timer.start(9000, open_final_room)
    sol.audio.play_music("victory")
    map:hero_freeze()
    map:hero_set_direction(3)
  end
end

function open_final_room()

  map:door_open("final_room_door")
  sol.audio.play_sound("secret")
  map:hero_unfreeze()
end

