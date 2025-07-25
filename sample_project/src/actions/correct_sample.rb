class CorrectSample 
  def initialize
    # We allow initialize methods as well
  end

  # Make sure wonky visibility orders don't break the lint rule
  private

  def private_method
  end

  public

  def execute
  end

  private

  def second_private
  end
   
end