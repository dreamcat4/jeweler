class Jeweler
  module Commands
    module Ghpages
      class ReleaseToGhpages < Base

        def run
          git_tag = nil
          commit_message = nil
          case ghpages_task.commit_tag
          when :release_tag
            git_tag = "gh-pages-" + release_tag
            commit_message = "Regenerated docs - #{release_tag}"
          when nil
            commit_message = "Regenerated docs"
          else
            git_tag = "gh-pages-" + ghpages_task.commit_tag.to_s
            commit_message = "Regenerated docs - #{ghpages_task.commit_tag.to_s}"
          end
          output.puts commit_message

          super

          grancher = Grancher.new
          ghpages_url = setup_grancher_return_ghpages_url(grancher)

          grancher.message = commit_message
          set_repo_homepage(ghpages_url) if ghpages_task.set_repo_homepage

          ghpages_task.map_paths.each do |src, dst|
            dst = nil if dst == ""
            grancher.file(src,dst)      if ::File.file?("#{repo.dir.path}/#{src}")
            grancher.directory(src,dst) if ::File.directory?("#{repo.dir.path}/#{src}")
          end
          commit_to_tag = grancher.commit

          if git_tag
            output.puts "Tagging #{git_tag}"
            grancher.tag(git_tag, commit_message, commit_to_tag)
            output.puts "Pushing #{git_tag}"
          else
            output.puts "Pushing gh-pages"
          end

          grancher.push
          output.puts "gh-pages - Done."
        end

      end
    end
  end
end
