require 'json'
require_relative '../services/message_service'
load 'config/settings.rb'

class Message < ActiveRecord::BaseAurora
  attr_reader :id, :created_at
  attr_accessor :content, :author_id
  attr_writer :timestamp
  
  def block_example
    [1, 2, 3].each { |num| puts num }
  end
end
