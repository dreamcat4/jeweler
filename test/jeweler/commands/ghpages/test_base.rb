require 'test_helper'

class Jeweler
  module Commands
    module Ghpages
      class TestBase < Test::Unit::TestCase

        ghpages_command_context "build for jeweler" do
          context "Jeweler::Commands::Ghpages::Base" do
            setup do
              @command = Jeweler::Commands::Ghpages::Base.build_for(@jeweler, @ghpages_task)

              @origin = Object.new
              stub(@repo).remote('origin') { @origin }
              stub(@origin).url { "git@github.com/user/repo" }
            end

            context "Jeweler::Commands::Ghpages::Base, def new_github_repo(repo_name, description, homepage)" do
              setup do
                @uri = Object.new
                stub(URI).parse('http://github.com/api/v2/yaml/repos/create') { @uri }

                stub(@command).gh_user { "user" }
                stub(@command).gh_token { "token" }

                @github_http_post_args = { 'login' => "user", 'token' => "token", 'name' => "repo",
                'description' => "description", 'homepage' => "homepage" }

                stub(Net::HTTP).post_form(@uri,@github_http_post_args) { true }
                @command.new_github_repo("repo", "description", "homepage")
              end

              should "follow the default calling path" do
                assert_received(URI) do |should_receive| 
                  should_receive.parse('http://github.com/api/v2/yaml/repos/create') { @uri }
                end

                assert_received(@command) do |should_receive| 
                  should_receive.gh_user { "user" }
                  should_receive.gh_token { "token" }
                end

                assert_received(Net::HTTP) do |should_receive| 
                  should_receive.post_form(@uri, @github_http_post_args) { true }
                end
              end
            end

            context "Jeweler::Commands::Ghpages::Base, def set_repo_homepage(url)" do
              setup do
                @uri = Object.new
                stub(URI).parse('http://github.com/api/v2/yaml/repos/show/user/repo') { @uri }

                stub(@command).gh_account { "user" }
                stub(@command).gh_repo { "repo" }
                stub(@command).gh_user { "user" }
                stub(@command).gh_token { "token" }

                @github_http_post_args = { 'login' => "user", 'token' => "token", 'values[homepage]' => "homepage" }

                stub(Net::HTTP).post_form(@uri,@github_http_post_args) { true }
                @command.set_repo_homepage("homepage")
              end

              should "follow the default calling path" do
                assert_received(URI) do |should_receive| 
                  should_receive.parse('http://github.com/api/v2/yaml/repos/show/user/repo') { @uri }
                end

                assert_received(@command) do |should_receive| 
                  should_receive.gh_user { "user" }
                  should_receive.gh_token { "token" }
                end

                assert_received(Net::HTTP) do |should_receive| 
                  should_receive.post_form(@uri, @github_http_post_args) { true }
                end
              end
            end

            context "Jeweler::Commands::Ghpages::Base, def release_tag()" do
              setup do
                stub(@command).version() { "0.1.2" }
                @command.release_tag
              end
              should "return the current version" do
                assert_received(@command) do |should_receive|
                  should_receive.version { "0.1.2" }
                end
              end
            end

            context "Jeweler::Commands::Ghpages::Base, def setup_grancher_return_ghpages_url()" do
              setup do
                @gash = Object.new
                stub(@gash).send(:git, 'remote', 'add', "user.github.com", "git@github.com:user/user.github.com.git") { true }

                @grancher = Object.new
                stub(@grancher).repo      { @g_repo }
                stub(@grancher).repo=("/path/to/user/repo")
                stub(@grancher).keep([])  { raise "Dont call @grancher.keep with an empty array. See: http://github.com/judofyr/grancher/issues/closed#issue/4/comment/173231" }
                stub(@grancher).push_to=("origin")
                stub(@grancher).branch=("gh-pages")
                stub(@grancher).refspec=("gh-pages:refs/heads/master")
                stub(@grancher).gash { @gash }

                @ghpages_task = Object.new
                stub(@ghpages_task).keep_files { [] }
                stub(@ghpages_task).user_github_com { false }

                stub(@command).repo { @repo }
                stub(@command).gh_user { "user" }
                stub(@command).gh_account { "user" }
                stub(@command).gh_repo { "repo" }
                stub(@command).ghpages_task { @ghpages_task }

                @output = Object.new
                stub(@command).output { @output }
                stub(@output).puts("Adding remote user.github.com to repo") { true }

                @remote = Object.new
                stub(@remote).name { "user.github.com" }

                @dir = Object.new
                stub(@repo).dir { @dir }
                stub(@dir).path { "/path/to/user/repo" }
                stub(@repo).remotes { [@remote] }
                stub(@command).new_github_repo("user.github.com", "Gh-pages pushed from user/repo", "http://user.github.com") { true }
              end
 
              context "run happily" do
                setup do
                  @command.setup_grancher_return_ghpages_url(@grancher)
                end

                should 'follow the default calling path' do
                  assert_received(@command) do |should_receive| 
                    should_receive.repo { @repo }
                    should_receive.gh_account { "user" }
                    should_receive.gh_repo { "repo" }
                  end

                  assert_received(@ghpages_task) do |should_receive|
                    should_receive.keep_files { [] }
                    should_receive.user_github_com { false }
                  end

                  assert_received(@repo) do |should_receive| 
                    should_receive.dir { @dir }
                  end

                  assert_received(@dir) do |should_receive| 
                    should_receive.path { "/path/to/user/repo" }
                  end
                end

                should "return the web url of the gh-pages site" do
                  @command.setup_grancher_return_ghpages_url(@grancher) { "http://user.github.com/repo" }
                end
              end
 
              context "with an array of repo-relative file paths to keep" do
                should "call @grancher.keep with that array of files" do
                  stub(@ghpages_task).keep_files { ["file1", "file2", "dir1", "dir2","etc..."] }
                  stub(@grancher).keep { ["file1", "file2", "dir1", "dir2","etc..."] }
                  @command.setup_grancher_return_ghpages_url(@grancher)
                  assert_received(@grancher) do |should_receive| 
                    should_receive.keep(["file1", "file2", "dir1", "dir2","etc..."])
                  end
                end
              end

              context "with the grancher configuration attribute 'user_github_com' set to true" do
                setup do
                  stub(@ghpages_task).user_github_com { true }
                  stub(@grancher).push_to=("user.github.com")
                  stub(@grancher).branch=("master")
                  @command.setup_grancher_return_ghpages_url(@grancher)
                end

                should 'follow the alternate calling path' do
                  assert_received(@command) do |should_receive| 
                    should_receive.repo { @repo }
                    should_receive.gh_account.times(any_times) { "user" }
                  end

                  assert_received(@ghpages_task) do |should_receive|
                    should_receive.keep_files { [] }
                    should_receive.user_github_com { false }
                  end

                  assert_received(@repo) do |should_receive| 
                    should_receive.dir { @dir }
                    should_receive.remotes
                  end

                  assert_received(@dir) do |should_receive| 
                    should_receive.path { "/path/to/user/repo" }
                  end
                end

                should "return the web url of the gh-pages root domain" do
                  @command.setup_grancher_return_ghpages_url(@grancher) { "http://user.github.com" }
                end

                context "with no prior git remote setup for the user_github_com (ie user.github.com)" do
                  should "add new remote 'user.github.com' onto the main jeweler.repo" do
                    stub(@remote).name { "origin" }
                    @command.setup_grancher_return_ghpages_url(@grancher)

                    assert_received(@command) do |should_receive| 
                      should_receive.repo { @repo }
                      should_receive.gh_account { "user" }
                      should_receive.new_github_repo("user.github.com", "Gh-pages pushed from user/repo", "http://user.github.com") { true }
                    end

                    assert_received(@repo) do |should_receive| 
                      should_receive.remotes.times(any_times) { @remote }
                    end

                    assert_received(@grancher) do |should_receive| 
                      should_receive.gash { @gash }
                    end

                    assert_received(@gash) do |should_receive| 
                      should_receive.send(:git, 'remote', 'add', "user.github.com", "git@github.com:user/user.github.com.git") { true }
                    end

                    assert_received(@remote) do |should_receive| 
                      should_receive.name.times(any_times) { "origin" }
                    end

                    assert_received(@output) do |should_receive| 
                      should_receive.puts("Adding remote user.github.com to repo") { true }
                    end
                  end
                end
              end
            end

            context "Jeweler::Commands::Ghpages::Base, def run()" do
              context "with an origin which is a valid github remote" do
                should "not raise any error" do
                  assert_nothing_raised do
                    @command.run
                  end
                end
              end

              context "with an origin which is not a github remote" do
                should 'raise an error' do
                  stub(@origin).url { "git@hosted_elsewhere/repo" }
                  assert_raises RuntimeError, /doesnt seem to be a Github url/i do
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
end

