class User < ActiveRecord::BaseAurora
  attr_reader :name, :email

  private

  attr_writer :password

  public

  def active?
    true
  end

  def foo
    true
  end

  def bar(biz: "Bizzzz")
    "#{biz}"
  end
end
