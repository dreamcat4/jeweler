class Jeweler
  module Commands
    module Ghpages
      class ReleaseToGhpages < Base

        def run
          super
          grancher = Grancher.new
          ghpages_url = setup_grancher_return_ghpages_url(grancher)
          if ghpages_task.user_github_com
            grancher.message = "Documentation update. Pushed from http://github.com/#{gh_account}/#{gh_repo} by #{gh_user}"
          else
            grancher.message = "Documentation update by #{gh_user}"
          end
          set_repo_homepage(ghpages_url) if ghpages_task.set_repo_homepage

          ghpages_task.map_paths.each do |src, dst|
            dst = nil if dst == ""
            grancher.file(src,dst)      if ::File.file?("#{repo.dir.path}/#{src}")
            grancher.directory(src,dst) if ::File.directory?("#{repo.dir.path}/#{src}")
          end

          output.puts "Pushing #{gh_repo}'s gh-pages to #{ghpages_url}"
          grancher.commit
          grancher.push
        end

      end
    end
  end
end
