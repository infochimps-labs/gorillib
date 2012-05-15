class Module
  #
  # Removes all constants in the module's namespace -- this is useful when
  # writing specs for metaprogramming methods
  #
  def nuke_constants

    constants.each{|const| remove_const(const) }
  end
end
