class Jeweler
  module Commands
    module Ghpages
      class RemoveFromGhpages < Base

        def run
          super
          grancher = Grancher.new
          ghpages_url = setup_grancher_return_ghpages_url(grancher)
          commit_msg = "Removed docs from gh-pages"
          grancher.message = commit_msg
          if ghpages_task.user_github_com && ghpages_task.keep_files.empty?
            FileUtils.mkdir_p "#{repo.dir.path}/doc"
            FileUtils.touch "#{repo.dir.path}/doc/.nojekyll"
            grancher.file "doc/.nojekyll", ".nojekyll"
          end
          grancher.commit
          grancher.push
          output.puts commit_msg
        end

      end
    end
  end
end
