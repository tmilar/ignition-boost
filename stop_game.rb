class Scene_Invaders < Scene_Base
  alias new_update update
  def update
    if($game_variables[Galv_SI::SCORE_VAR] >= $game_variables[103])
#Input::setButton(:B)
      SceneManager.goto(Scene_Map)
    end
    new_update
  end
end