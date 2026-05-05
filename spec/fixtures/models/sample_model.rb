class SampleModel < ActiveRecord::Base
  attr_reader :name

  def full_name
    name
  end
end
