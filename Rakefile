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
end

task :compile => ['lib/gql/tokenizer.rb', 'lib/gql/parser.rb']

Rake::TestTask.new :test => :compile do |t|
  t.libs << 'test'
end

task :default => :test
