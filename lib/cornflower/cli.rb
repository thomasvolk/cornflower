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
      
        if output_filename
            File.open(output_filename, 'w') { |output_file| 
              parse_model(input_file, output_file)
            }
        else
          s = StringIO.new
          parse_model(input_file, s)
          puts s.string
        end
      end

      def parse_model(input_file, out)
        model = eval File.read(input_file)

        plantuml = Cornflower::Export::PlanUMLExporter.new

        out << "\n@startuml\n\n"
        plantuml.export(model, out)
        out << "\n@enduml\n"
      end

    end

  end
end