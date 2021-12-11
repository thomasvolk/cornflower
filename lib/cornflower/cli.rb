require 'optionparser'
require 'cornflower/export/plantuml'
require 'cornflower/filter'
require 'cornflower/walker'
require 'cornflower/version'
require 'cornflower'
require 'stringio'

module Cornflower
  module Cli  
    def self.split_list(list)
      list.split(',').map { |t| t.strip.to_sym }
    end

    class App
      BANNER = "Usage: cornflower [options] inputfile"

      def run       
        output_filename = nil    
        tags_to_include = nil
        tags_to_exclude = nil
        
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
          opts.on("-t", "--tags TAGS", "comma separated tag list to include") do |tags_list|
            tags_to_include = Cornflower::Cli::split_list(tags_list)
          end
          opts.on("-e", "--tags-exclude TAGS", "comma separated tag list to exlude") do |tags_list|
            tags_to_exclude = Cornflower::Cli::split_list(tags_list)
          end
        end.parse!
            
        input_file = ARGV.pop
        abort("No inputfile given!\n#{BANNER}") unless input_file
      
        model = eval File.read(input_file)
        model.sealed = true
        walker = Cornflower::Walker.new model
        
        filters = []
        if tags_to_include != nil
          filters << Cornflower::Filter::tags(tags_to_include)
        end
        if tags_to_exclude != nil
          filters << Cornflower::Filter::tags(tags_to_exclude, true)
        end
        walker.filter = Cornflower::Filter::FilterChain.new filters

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