require 'grancher'

class Jeweler
  module Commands
    module Ghpages
      class Base
        attr_accessor :version, :repo, :output, :ghpages_task

        def initialize(attributes = {})
          self.output = $stdout

          attributes.each_pair do |key, value|
            send("#{key}=", value)
          end
        end

        def parse_opt(args,opt)
          args = args.dup
          require 'optparse'
          @opts = OptionParser.new do |o|
            o.on("#{opt}") do |val|
              return val
            end
          end

          begin
            @opts.parse!(args)
          rescue OptionParser::InvalidOption => e
            return nil
          end
        end

        def gh_user
          user = repo.config["github.user"] || parse_opt(ENV['JEWELER_OPTS'].split,"--github-username")
          raise "Couldnt find your Github username. Did you add it to ~/.gitconfig ?" unless user
          user
        end

        def gh_token
          token = repo.config["github.token"] || parse_opt(ENV['JEWELER_OPTS'].split,"--github-token")            
          raise "Couldnt find your Github auth token. Did you add it to ~/.gitconfig ?" unless token
          token
        end

        def gh_account
          repo.remote('origin').url.match(/\:(.*)\//)[1]
        end

        def gh_repo
          repo.remote('origin').url.match(/\/(.*)\.git/)[1]
        end

        def new_github_repo(repo_name, description, homepage)
          Net::HTTP.post_form URI.parse('http://github.com/api/v2/yaml/repos/create'),
            'login' => gh_user, 'token' => gh_token, 'name' => repo_name,
            'description' => description, 'homepage' => homepage
        end

        def set_repo_homepage(url)
          Net::HTTP.post_form URI.parse("http://github.com/api/v2/yaml/repos/show/#{gh_account}/#{gh_repo}"),
            'login' => gh_user, 'token' => gh_token, 'values[homepage]' => url
        end
        
        def release_tag
          "v#{version}"
        end

        def setup_grancher_return_ghpages_url(grancher)
          grancher.repo = repo.dir.path
          grancher.keep(ghpages_task.keep_files) unless ghpages_task.keep_files.empty?

          ghpages_user_domain = "#{gh_account}.github.com"

          if ghpages_task.user_github_com

            ghpages_url = "http://#{ghpages_user_domain}"
            grancher.push_to = ghpages_user_domain
            grancher.refspec = 'gh-pages:refs/heads/master'

            remotes = repo.remotes.map {|r| r.name }
            unless remotes.include?(ghpages_user_domain)
              output.puts "Adding remote #{ghpages_user_domain} to repo"
              user_github_com_uri = "git@github.com:#{gh_account}/#{ghpages_user_domain}.git"
              grancher.gash.send(:git, 'remote', 'add', ghpages_user_domain, user_github_com_uri)
              new_github_repo(ghpages_user_domain, "Gh-pages pushed from #{gh_account}/#{gh_repo}", ghpages_url)
            end
          else
            ghpages_url = "http://#{ghpages_user_domain}/#{gh_repo}"
            grancher.push_to = 'origin'
            grancher.branch = 'gh-pages'
          end
        
          ghpages_url
        end

        def self.build_for(jeweler, ghpages_task)
          command = self.new
          command.ghpages_task = ghpages_task
          command.version = jeweler.version
          command.repo = jeweler.repo
          command.output = jeweler.output
        
          command
        end
 
        def run
          raise "Remote origin doesnt seem to be a Github url" unless repo.remote('origin').url =~ /github\.com/
        end

      end
    end
  end
end
