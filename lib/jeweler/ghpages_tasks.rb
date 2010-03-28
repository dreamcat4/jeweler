require 'rake'
require 'rake/tasklib'

class Jeweler
  # (New) Rake tasks for pushing gem documentation to Github Pages.
  #
  # Jeweler::Tasks.new needs to be used before this.
  #
  # Basic usage:
  #
  #     Jeweler::GhpagesTasks.new
  #
  # There are a few options you can tweak:
  #
  #  * push_on_release: Specify whether jeweler should update and release documentation, whenever the gem is released. Defaults to false.
  #  * set_repo_homepage: Set to true, and the Github Pages you push will be set as the "Homepage" link on your github repo. Note: this is a different
  #    link than the gem specification's "homepage" field, which is used by gemcutter (and points to your github repo page). Defaults to true.
  #  * user_github_com: Specify that jewler should push documentation to github special "username.github.com" repo, url "username.github.com".
  #    The Default is false, which means push to the regular gh-pages branch, and url "username.github.com/repo".
  #  * doc_task: The format to be used for generating documentation, before its uploaded. Defaults to "rdoc".
  #  * keep_files: An array of files and directories to keep (not wipe out) on the gh-pages branch. Defaults to [].
  #  * map_paths: A hash map of the files to upload to gh-pages, and describes the structure of the ghpages site. This is a hash of 
  #    key => value pairs. The format is: "source_file_or_dir" => "target_file_or_dir". All paths must be specified path-relative 
  #    from the repository's root directory, or gh-pages site root. For example, you might use "_site" => "" to map a jekyll website 
  #    into root of your ghpages site, and then use "rdoc" => "rdoc" to map the rdoc documentation as a subfolder of that site. 
  #    Defaults to { 'rdoc' => '' }.
  #
  # See also http://wiki.github.com/technicalpickles/jeweler/ghpages
  class GhpagesTasks < ::Rake::TaskLib
    # Specify whether jeweler should update and release documentation, whenever the gem is released. Defaults to true.
    attr_accessor :push_on_release

    # Set to true, and the Github Pages you push will be set as the "Homepage" link on your github repo. Note: this is a different
    # link than the gem specification's "homepage" field, which is used by gemcutter (and points to your github repo page). Defaults to true.
    attr_accessor :set_repo_homepage

    # Specify that jewler should push documentation to github special "username.github.com" repo, url "username.github.com".
    # The Default is false, which means push to the regular gh-pages branch, and url "username.github.com/repo".
    attr_accessor :user_github_com

    # The format to be used for generating documentation, before its uploaded. Defaults to "rdoc".
    attr_accessor :doc_task

    # An array of files and directories to keep (not wipe out) on the gh-pages branch. Defaults to [].
    attr_accessor :keep_files

    # A hash map of the files to upload to gh-pages, and describes the structure of the ghpages site. This is a hash of 
    # key => value pairs. The format is: "source_file_or_dir" => "target_file_or_dir". All paths must be specified path-relative 
    # from the repository's root directory, or gh-pages site root. For example, you might use "_site" => "" to map a jekyll website 
    # into root of your ghpages site, and then use "rdoc" => "rdoc" to map the rdoc documentation as a subfolder of that site. 
    # Defaults to { 'rdoc' => '' }.
    attr_accessor :map_paths


    attr_accessor :jeweler

    def initialize

      yield self if block_given?

      define
    end

    def jeweler
      @jeweler ||= Rake.application.jeweler
    end

    def push_on_release
      if @push_on_release.nil?
        @push_on_release = true
      else
        @push_on_release
      end
    end

    def doc_task
      @doc_task ||= "rdoc"
    end

    def keep_files
      @keep_files ||= []
    end

    def user_github_com
      @user_github_com ||= false
    end

    def map_paths
      unless @map_paths
        case doc_task
        when "rdoc"
          @map_paths ||= { "rdoc" => "" }
        when "yard"
          @map_paths ||= { "doc" => "" }
        end
      end
      @map_paths
    end

    def set_repo_homepage
      @set_repo_homepage ||= true
    end

    def define

      namespace :ghpages do
        namespace :release do

          ["rdoc", "yard"].each do |doc_task|
            desc "Release #{doc_task} documentation to Github Pages"
            task doc_task.to_sym => "rake:#{doc_task}" do
              jeweler.release_docs_to_ghpages(self)
            end
          end
        end

        desc "Release #{doc_task} documentation to Github Pages"
        task :release => "ghpages:release:#{doc_task}"

        task :takedown do
          jeweler.remove_docs_from_ghpages(self)
        end
      end

      if push_on_release
        task :release => 'ghpages:release'
      end

    end
  end
end

