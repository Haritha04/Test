desc 'Run the tests'
task :test do
  exec('xctool/xctool.sh -project TestProject/TestProject.xcodeproj -scheme MyAppTests test')
end

task :default => :test
