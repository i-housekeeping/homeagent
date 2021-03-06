# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

require 'fileutils'
include FileUtils

# set constant values:
LIB_FOLDER = File.expand_path('../')
INSTALL_FOLDER = File.expand_path('../myhomeagent')
NSIS = "C:/Program Files/NSIS/makensis.exe"
RESHACKER = "C:/workspace/ResHack/ResHacker.exe"
NSIS_FILE = "#{INSTALL_FOLDER}/homeagent.nsi"
README_FILE = "#{INSTALL_FOLDER}/RELEASENOTES"

# extract values from main.rb file:
#main_rb = open('../homeagent.rb').read
#APP_TITLE = main_rb.scan(/APP_TITLE = '(.+)'/)[0][0]
EXE_NAME = 'homeagent.exe'  #main_rb.scan(/EXE_NAME = '(.+)'/)[0][0]
#EXE_BASENAME = EXE_NAME.gsub('.exe', '')
#APP_VERSION = main_rb.scan(/APP_VERSION = '(.+)'/)[0][0]
APP_VERSION = '0.1'


# rake tasks:
task :default => [:create_setup]

namespace :homeagent do
 
  desc "Create homeagentsetup.exe and move to i-housekeeping folder for futher deployment"
  task :create_setup => [:move_exe, :modify_icon, :edit_readme] do
      #puts "Creating setup.exe"
      Dir.chdir(INSTALL_FOLDER)
      system(NSIS, NSIS_FILE)
      mv("homeagentsetup.exe", "../i-housekeeping/lib/install/homeagentsetup.exe")
  end
  
  
  desc "Edit releasenotes.txt"
  task :edit_readme do
      #puts "Updating ReadMe.txt file"
      Dir.chdir(INSTALL_FOLDER)
      txt = nil
      open(README_FILE) do |f|
          txt = f.read
      end
      #old_version = txt.scan(/Version (\d\d\.\d\d\.\d\d)/)[0][0]
      txt = "Internet Housekeeping version #{APP_VERSION}"  #txt.gsub(old_version, APP_VERSION)
      File.delete(README_FILE)
      open(README_FILE, 'w') do |f|
          f.puts(txt)
      end
  end
  
  desc "Modify EXE icon"
  task :modify_icon => [:move_exe] do
      #puts "Modifying EXE icon"
      Dir.chdir(INSTALL_FOLDER)
      arg = " -addoverwrite #{EXE_NAME}, #{EXE_NAME}, favicon.ico, 
            icongroup, appicon, 0"
      system(RESHACKER + arg)
  end
  
  desc "Move EXE to install folder"
  task :move_exe => [:compile_code] do
      #puts "Moving EXE to install folder"
      mv("homeagent.exe", "#{INSTALL_FOLDER}/#{EXE_NAME}")
  end
  
  desc "Compile code into EXE"
  task :compile_code do
      #puts "Compiling main.rb into EXE"
      system("tar2rubyscript.cmd", "#{LIB_FOLDER}/homeagent\\")
      system("rubyscript2exe.cmd", "#{LIB_FOLDER}/homeagent.rb")
  end
end

namespace :db do
  desc 'Create YAML test fixtures from data in an existing database.  
  Defaults to development database. Set RAILS_ENV to override.'

  task :extract_fixtures => :environment do
    sql = "SELECT * FROM %s"
    skip_tables = ["schema_info", "sessions"]
    ActiveRecord::Base.establish_connection
    tables = ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : ActiveRecord::Base.connection.tables - skip_tables
    tables.each do |table_name|
      i = "000"
      File.open("#{RAILS_ROOT}/db/#{table_name}.yml", 'w') do |file|
        data = ActiveRecord::Base.connection.select_all(sql % table_name)
        file.write data.inject({}) { |hash, record|
          hash["#{table_name}_#{i.succ!}"] = record
          hash
        }.to_yaml
      end
    end
  end
end