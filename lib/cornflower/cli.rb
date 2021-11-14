require 'optionparser'
require 'cornflower/export/plantuml'
require 'cornflower'
require 'stringio'

module Cornflower
  module Cli  
    class App
      BANNER = "Usage: cornflower [options] inputfile"

      def run       
        output_filename = nil    
        
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
        end.parse!
            
        input_file = ARGV.pop
        abort("No inputfile given!\n#{BANNER}") unless input_file
      
        model = eval File.read(input_file)
        exporter = Cornflower::Export::PlanUMLExporter.new

        if output_filename
            File.open(output_filename, 'w') { |output_file| 
              exporter.export(model, output_file)
            }
        else
          s = StringIO.new
          exporter.export(model, s)
          puts s.string
        end
      end

    end

  end
end