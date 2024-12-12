class User < ActiveRecord::Base
  def active?
    true
  end

  def foo
    true
  end
end
