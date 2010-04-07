require 'test_helper'

class Jeweler
  module Commands
    module Ghpages
      class TestRemoveFromGhpages < Test::Unit::TestCase

        ghpages_command_context "build for jeweler" do
          context "Jeweler::Commands::Ghpages::RemoveFromGhpages" do
            setup do

          	  @grancher = Object.new

              Grancher.class_eval do
                def self.instance(instance=nil)
                  if instance
                    @instance = instance
                  else
                    @instance
                  end
                end
                def self.new(*args, &blk)
                  if blk
                    if blk.arity == 1
                      blk.call(instance)
                    else
                      instance.instance_eval(&blk)
                    end
                  end
                  return instance
                end
              end

              self.instance_eval do
                class Grancher
                end
              end

              ::Grancher.instance @grancher

              stub(@grancher).commit { true }
              stub(@grancher).push { true }
              stub(@grancher).message=("Removing gh-pages from http://user.github.com/repo")

              @output = Object.new
              stub(@output).puts("Removing gh-pages from http://user.github.com/repo") { true }

              @command = Jeweler::Commands::Ghpages::RemoveFromGhpages.build_for(@jeweler, @ghpages_task)
              stub(@command).setup_grancher_return_ghpages_url(@grancher) { "http://user.github.com/repo" }
              stub(@command).output { @output }
              stub(@command).clean_staging_area? { true }
              @origin = Object.new
              stub(@repo).remote('origin') { @origin }
              @dir = Object.new
              stub(@repo).dir { @dir }
              stub(@dir).path { "/path/to/user/repo" }
              stub(@origin).url { "git@github.com/user/repo" }

              stub(@command).repo { @repo }
              stub(@command).grancher { @grancher }
              stub(@command).gh_repo { "repo" }
              stub(@command).gh_account { "user" }
            end

            context "Jeweler::Commands::Ghpages::RemoveFromGhpages, def run()" do
              should "follow the default calling path" do
                @command.run

                assert_received(@command) do |should_receive| 
                  should_receive.setup_grancher_return_ghpages_url(@grancher) { "http://user.github.com/repo" }
                  should_receive.set_repo_homepage("http://user.github.com/repo") { true }
                  should_receive.repo.times(any_times) { @repo }
                  should_receive.gh_account.times(any_times) { "user" }
                  should_receive.gh_repo.times(any_times) { "repo" }
                end
 
                assert_received(@repo) do |should_receive| 
                  should_receive.dir.times(any_times) { @dir }
                end

                assert_received(@grancher) do |should_receive| 
                  should_receive.commit { true }              		
                  should_receive.push { true }
                end

                assert_received(@output) do |should_receive| 
                  should_receive.puts("Removing gh-pages from http://user.github.com/repo") { true }
                end

                assert_received(@dir) do |should_receive| 
                  should_receive.path.times(any_times) { "/path/to/user/repo" }
                end
              end

              should "not raise any error" do
                assert_nothing_raised do
                  @command.run
                end
              end
            end

            context "with the grancher configuration attribute 'user_github_com' set to true" do
              setup do
                stub(@ghpages_task).user_github_com { true }
                stub(@ghpages_task).keep_files { [] }
                stub(FileUtils).mkdir_p("/path/to/user/repo/doc") { true }
                stub(FileUtils).touch("/path/to/user/repo/doc/.nojekyll") { true }
                stub(@grancher).file("doc/.nojekyll",".nojekyll") { true }
                @command.run
              end

              should 'follow the alternate calling path' do
                assert_received(@ghpages_task) do |should_receive|
                  should_receive.user_github_com { true }
                  should_receive.keep_files { [] }
                end
                
                assert_received(@repo) do |should_receive| 
                  should_receive.dir.times(any_times) { @dir }
                end
                
                assert_received(@dir) do |should_receive| 
                  should_receive.path.times(any_times) { "/path/to/user/repo" }
                end

                assert_received(FileUtils) do |should_receive|
                  should_receive.mkdir_p("/path/to/user/repo/doc") { true }
                  should_receive.touch("/path/to/user/repo/doc/.nojekyll") { true }
                end

                assert_received(@grancher) do |should_receive|
                  should_receive.file("doc/.nojekyll",".nojekyll") { true }
                end
              end
            end
          end
        end
      end
    end
  end
end

