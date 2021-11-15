require 'optionparser'
require 'cornflower/export/plantuml'
require 'cornflower/filter'
require 'cornflower'
require 'stringio'

module Cornflower
  module Cli  
    class App
      BANNER = "Usage: cornflower [options] inputfile"

      def run       
        output_filename = nil    
        tags = []
        
        parser = OptionParser.new do |opts|
          opts.banner = BANNER
          opts.on('-v', '--version', 'show version') do
            puts Cornflower::VERSION  
            exit
          end
          opts.on("-h", "--help", "print help") do
            puts opts
            exit
          end
          opts.on("-o", "--output FILENAME", "output filename") do |file_name|
            output_filename = file_name
          end
          opts.on("-t", "--tags TAGS", "comma separated tag list") do |tags_list|
            tags = tags_list.split(',').map { |t| t.strip.to_sym }
          end
        end.parse!
            
        input_file = ARGV.pop
        abort("No inputfile given!\n#{BANNER}") unless input_file
      
        model = eval File.read(input_file)
        exporter = Cornflower::Export::PlanUMLExporter.new
        filter = Cornflower::Filter::tags(*tags)


        if output_filename
            File.open(output_filename, 'w') { |output_file| 
              exporter.export(model, output_file, filter)
            }
        else
          s = StringIO.new
          exporter.export(model, s, filter)
          puts s.string
        end
      end

    end

  end
end