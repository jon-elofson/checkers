class Player

  attr_reader :name, :color

  def initialize(name,color)
    @name = name
    @color = color
  end

  def dispcolor
    if @color == :light_blue
      return "BLUE"
    else
      return "RED"
    end
  end

  def prompt
  end

end
