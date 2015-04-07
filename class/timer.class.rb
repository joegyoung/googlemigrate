class Timer

  def initialize
    @start_time = Time.now()
  end
  def stop
    @end_time = Time.now()
    t = (@end_time - @start_time).to_f
    puts "Total time: [#{t}]"
  end

end
#timer = Timer.new()
#timer.stop