require 'jeweler/ghpages_tasks'

class Jeweler
  class Generator
    module GhpagesMixin
      def self.extended(generator)
        generator.ghpages_tasks = Jeweler::GhpagesTasks.new
        generator.ghpages_tasks.doc_task = generator.documentation_framework

        generator.development_dependencies <<  ["grancher", ">= 0"]
      end
    end
  end
end

