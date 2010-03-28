require 'jeweler/ghpages_tasks'

class Jeweler
  class Generator
    class_option :ghpages, :type => :boolean, :default => false,
      :desc => 'push documentation to ghpages'

    class Ghpages < Plugin

      class_option :ghpages, :type => :boolean, :default => false,
        :desc => 'generate rake task for ghpages'

      def initialize(generator, doc_task)
        super(generator)

        use_inline_templates! __FILE__

        ghpages_tasks = Jeweler::GhpagesTasks.new
        ghpages_tasks.doc_task = doc_task

        e = ERB.new(lookup_inline_template(:rakefile_snippet),nil,'<>')
        rakefile_snippets << e.result(binding)
        
        development_dependencies <<  ["grancher", ">= 0"]
      end

    end
  end
end
__END__
@@ rakefile_snippet
Jeweler::GhpagesTasks.new do |ghpages|
  ghpages.push_on_release   = <%= ghpages_tasks.push_on_release %>
  ghpages.set_repo_homepage = <%= ghpages_tasks.set_repo_homepage %>
  ghpages.user_github_com   = <%= ghpages_tasks.user_github_com %>
  ghpages.doc_task    = "<%= ghpages_tasks.doc_task %>"
  ghpages.keep_files  = <%= ghpages_tasks.keep_files.inspect %>
  ghpages.map_paths   = {
    <% ghpages_tasks.map_paths.each do |k,v| %>"<%= k %>" => "<%= v %>",<% end %>
  }
end
