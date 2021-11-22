require 'optionparser'
require 'cornflower/export/plantuml'
require 'cornflower/filter'
require 'cornflower/walker'
require 'cornflower/version'
require 'cornflower'
require 'stringio'

module Cornflower
  module Cli  
    class App
      BANNER = "Usage: cornflower [options] inputfile"

      def run       
        output_filename = nil    
        tags = nil
        tags_exclude = false
        
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
          opts.on("-e", "--tags-exclude", "exclude all nodes of the given tags (works only together with -t)") do
            tags_exclude = true
          end
        end.parse!
            
        input_file = ARGV.pop
        abort("No inputfile given!\n#{BANNER}") unless input_file
      
        model = eval File.read(input_file)
        model.sealed = true
        walker = Cornflower::Walker.new model
        if tags != nil
          walker.filter = Cornflower::Filter::tags tags, invert = tags_exclude 
        end

        if output_filename
            File.open(output_filename, 'w') { |output_file| 
              exporter = Cornflower::Export::PlanUMLExporter.new output_file
              walker.walk exporter
            }
        else
          s = StringIO.new
          exporter = Cornflower::Export::PlanUMLExporter.new s
          walker.walk exporter
          puts s.string
        end
      end

    end

  end
end