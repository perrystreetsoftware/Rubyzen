class Message < ActiveRecord::BaseAurora
  def block_example
    [1, 2, 3].each { |num| puts num }
  end
end
