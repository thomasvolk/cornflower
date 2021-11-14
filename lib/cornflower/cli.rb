require 'optionparser'
require 'cornflower/export/plantuml'
require 'cornflower'
require 'stringio'

module Cornflower
  module Cli  
    class App
      BANNER = "Usage: cornflower [options] inputfile"

      def run           
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
        end.parse!
            
        inputfile = ARGV.pop
        abort("No inputfile given!\n#{BANNER}") unless inputfile
      
        model = eval File.read(inputfile)

        plantuml = Cornflower::Export::PlanUMLExporter.new

        s = StringIO.new

        s << "\n@startuml\n\n"
        plantuml.export(model, s)
        s << "\n@enduml\n"

        puts s.string
      end

    end

  end
end