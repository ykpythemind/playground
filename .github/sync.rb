require 'tmpdir'
require 'fileutils'
require 'pathname'

Repository = Struct.new(:url)
Strategy = Struct.new(:dest_dir, keyword_init: true)

repos = [
  Repository.new('git@github.com:ykpythemind/playground.git'),
  Repository.new('git@github.com:ykpythemind/sandbox.git'),
]
strategy = Strategy.new(dest_dir: '.github')

target_file = ARGF.argv[0]

if !target_file
  abort 'target_file is not given'
end

target_file = File.new(target_file, "r")

def system!(cmd)
  system(cmd, exception: true)
end

def with_cloned_dir(repo, &block)
  Dir.mktmpdir do |dir|
    system!("git -C #{dir} clone --depth 1 #{repo.url} .")
    puts "cloned #{repo.url}"
    Dir.chdir(dir) do
      yield dir
    end
  end
end

repos.each do |repo|
  with_cloned_dir(repo) do |dir|
    if strategy.dest_dir
      system!("mkdir -p #{strategy.dest_dir}")
    end
    FileUtils.cp(target_file.path, strategy.dest_dir || './')

    system!("git add .")
    system!("git commit -m 'copy #{Pathname.new(target_file.path).basename}'")
    system!("git status")
    system!("git push")
  end
end

