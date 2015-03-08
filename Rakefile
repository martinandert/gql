dir = File.dirname(__FILE__)

require 'bundler/gem_tasks'
require 'rake/testtask'

file 'lib/gql/tokenizer.rb' => 'support/tokenizer.rex' do |t|
  sh "bundle exec rex #{t.prerequisites.first} --output-file #{t.name}"

  # use custom scan error class
  sh "sed --in-place 's/class ScanError/class Unused/' #{t.name}"
  sh "sed --in-place 's/ScanError/GQL::Errors::ScanError/' #{t.name}"
end

file 'lib/gql/parser.rb' => 'support/parser.racc' do |t|
  if ENV['DEBUG']
    sh "bundle exec racc --debug --verbose --output-file=#{t.name} #{t.prerequisites.first}"
  else
    sh "bundle exec racc --output-file=#{t.name} #{t.prerequisites.first}"
  end

  # fix indentation of generated parser code to silence test warning
  sh "sed --in-place 's/  end\s*# module/end #/g' #{t.name}"
end


Rake::TestTask.new :test do |t|
  t.libs << 'test'
  t.test_files = Dir.glob("#{dir}/test/cases/**/*_test.rb")
# t.warning = true
# t.verbose = true
end

task :compile => ['lib/gql/tokenizer.rb', 'lib/gql/parser.rb']
task :test    => :compile
task :build   => :test
task :default => :test
