module AresMUSH
  module Idle
    def self.can_idle_sweep?(actor)
      actor.has_any_role?(Global.read_config("idle", "roles", "can_idle_sweep"))
    end

    def self.is_exempt?(actor)
      actor.has_any_role?(Global.read_config("idle", "roles", "idle_exempt"))
    end
        
    def self.active_chars
      base_list = Character.all
      base_list.select { |c| !(c.idled_out? || c.is_admin? || c.is_playerbit? || c.is_guest?)}
    end
    
  end
end