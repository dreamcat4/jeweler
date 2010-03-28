require 'test_helper'

class Jeweler
  module Commands
    module Ghpages
      class TestReleaseToGhpages < Test::Unit::TestCase

        ghpages_command_context "build for jeweler" do
          context "Jeweler::Commands::Ghpages::ReleaseToGhpages" do
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
              stub(@grancher).message=("Documentation update by user")

              @ghpages_task = Object.new
              stub(@ghpages_task).user_github_com { false }
              stub(@ghpages_task).set_repo_homepage { true }
              stub(@ghpages_task).map_paths do
                {
                  "file1" => "file1",
                  "file2" => "",
                  "dir1"  => "dir1" ,
                  "dir2"  => nil
                }
              end

              stub(::File).file?("/path/to/user/repo/file1") { true }
              stub(::File).directory?("/path/to/user/repo/file1") { false }
          		stub(@grancher).file("file1","file1") { true }

              stub(::File).file?("/path/to/user/repo/file2") { true }
              stub(::File).directory?("/path/to/user/repo/file2") { false }
          		stub(@grancher).file("file2",nil) { true }

              stub(::File).file?("/path/to/user/repo/dir1") { false }
              stub(::File).directory?("/path/to/user/repo/dir1") { true }
          		stub(@grancher).directory("dir1","dir1") { true }

              stub(::File).file?("/path/to/user/repo/dir2") { false }
              stub(::File).directory?("/path/to/user/repo/dir2") { true }
          		stub(@grancher).directory("dir2",nil) { true }

              @output = Object.new
              stub(@output).puts("Pushing repo's gh-pages to http://user.github.com/repo") { true }

              @command = Jeweler::Commands::Ghpages::ReleaseToGhpages.build_for(@jeweler, @ghpages_task)
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
              stub(@command).ghpages_task { @ghpages_task }
              stub(@command).gh_account { "user" }
              stub(@command).gh_user { "user" }
              stub(@command).gh_repo { "repo" }
              stub(@command).set_repo_homepage("http://user.github.com/repo") { true }
            end

            context "Jeweler::Commands::Ghpages::ReleaseToGhpages, def run()" do
              should "follow the default calling path" do
                @command.run

                assert_received(@command) do |should_receive| 
                  should_receive.setup_grancher_return_ghpages_url(@grancher) { "http://user.github.com/repo" }
                  should_receive.set_repo_homepage("http://user.github.com/repo") { true }
                  should_receive.repo.times(any_times) { @repo }
                end

                assert_received(@ghpages_task) do |should_receive|
                  should_receive.set_repo_homepage { true }
                  should_receive.gh_repo { "repo" }
                  should_receive.map_paths do
                    {
                      "file1" => "file1",
                      "file2" => "",
                      "dir1"  => "dir1" ,
                      "dir2"  => nil
                    }
                  end
                end

                assert_received(::File) do |should_receive|
                  should_receive.file?("/path/to/user/repo/file1") { true }
                  should_receive.directory?("/path/to/user/repo/file1") { false }
                  should_receive.file?("/path/to/user/repo/file2") { true }
                  should_receive.directory?("/path/to/user/repo/file2") { false }
                  should_receive.file?("/path/to/user/repo/dir1") { false }
                  should_receive.directory?("/path/to/user/repo/dir1") { true }
                  should_receive.file?("/path/to/user/repo/dir2") { false }
                  should_receive.directory?("/path/to/user/repo/dir2") { true }
                end

                assert_received(@repo) do |should_receive| 
                  should_receive.dir.times(any_times) { @dir }
                end

                assert_received(@grancher) do |should_receive| 
                  should_receive.message("Documentation update by user")
              		should_receive.file("file1","file1") { true }
              		should_receive.file("file2",nil) { true }
              		should_receive.directory("dir1","dir1") { true }
              		should_receive.directory("dir2",nil) { true }
                  should_receive.commit { true }              		
                  should_receive.push { true }
                end

                assert_received(@output) do |should_receive| 
                  should_receive.puts("Pushing repo's gh-pages to http://user.github.com/repo") { true }
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

          end
        end
      end
    end
  end
end

