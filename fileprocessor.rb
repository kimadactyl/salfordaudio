require "./models"

class ProcessorQueue

  def initialize
    # Start the queue
    puts "Queue starting."
    @running = true
    # Get the next ticket
    next_ticket
  end

  def next_ticket
    # Find next unprocessed ticket sorted by number order
    ticket = Audio.first(:processed => false)
    if(ticket)
      # If there's a ticket to process, go do that
      @ticket = ticket.id
      puts "Next ticket: #{@ticket}"
      process(@ticket)
    else
      # If not, stop the queue
      puts "No files to process. Shutting down."
      @running = false
    end
  end

  def process(id)
    # Process a file given an ID
    a = Audio.get(id)
    puts "#{id}: Starting processing"
    input = a.source.path
    puts "Source path is #{input}. Starting..."
    output = File.dirname(input)
    # Run the windDet binary
    `./windDet -i #{input} -o #{output}/output`
    puts "#{a.id}: Processing complete"
    # Mark it as complete in the database
    a.processed = true
    a.save
    # Check for the next file
    next_ticket
  end

  def check_if_running
    # To be used post-form submit to check the queue is running.
    # If it's not, process it now.
    if @running == false
      @running = true
      next_ticket 
    end
  end

  def current_ticket
    # Output current ticket status
    @ticket
  end

end

# Start the thing up
queue = ProcessorQueue.new