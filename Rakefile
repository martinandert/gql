dir = File.dirname(__FILE__)

require 'bundler/gem_tasks'
require 'rake/testtask'

file 'lib/gql/tokenizer.rb' => 'lib/gql/tokenizer.rex' do |t|
  sh "bundle exec rex #{t.prerequisites.first} --output-file #{t.name}"
end

file 'lib/gql/parser.rb' => 'lib/gql/parser.y' do |t|
  if ENV['DEBUG']
    sh "bundle exec racc --debug --verbose --output-file=#{t.name} #{t.prerequisites.first}"
  else
    sh "bundle exec racc --output-file=#{t.name} #{t.prerequisites.first}"
  end

  # fix test warning
  c = File.read(t.name)
  File.open t.name, 'w' do |f|
    f.write c.sub(/\n\s+end\s*# module GQL[\s\n]*$/, "\nend\n")
  end
end

task :compile => ['lib/gql/tokenizer.rb', 'lib/gql/parser.rb']

Rake::TestTask.new :test => :compile do |t|
  t.libs << 'test'
  t.test_files = Dir.glob("#{dir}/test/cases/**/*_test.rb")
  t.warning = true
# t.verbose = true
end

task :default => :test
