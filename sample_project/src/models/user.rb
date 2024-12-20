class User < ActiveRecord::BaseAurora
  def active?
    true
  end

  def foo
    true
  end
end
