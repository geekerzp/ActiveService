#coding : utf-8
require 'digest'
require 'fileutils'
require 'json'
#
#  资源相关的rake任务
#
namespace :resources do
  #
  # 加密resources文件
  #
  root = GGA.root
  desc '加密resources文件'
  task(:encode_resource_files) do
    system("cd #{root}/data;for f in `find . -type f`; do cp $f . > /dev/null 2>&1 ;done;")
    system("rm -rf #{root}/public/sd; rm -rf #{root}/public/hd;")
    system("mkdir #{root}/public/sd; mkdir #{root}/public/hd;")

    inDirPath = "#{root}/data/"
    resources_list = []
    resource = {list: resources_list}
    puts "#{inDirPath}"
    Dir.foreach(inDirPath) do |file|
      if FileTest::file?("#{inDirPath}/#{file}") && file[0] != '.'
        if file.include?('.pvr')
          newFileName = "#{Digest::MD5.hexdigest(file)}.pvr.ccz"
        else
          newFileName = "#{Digest::MD5.hexdigest(file)}.#{file.split('.')[-1]}"
        end

        tmp = {}
        fileMd5Sum = ''
        File.open("#{inDirPath}/#{file}", "r") {|f| fileMd5Sum = Digest::MD5.hexdigest(File.read(f))}
        tmp[:filename] = newFileName
        tmp[:md5] = fileMd5Sum
        tmp[:size] = File.size("#{inDirPath}/#{file}")
        resources_list << tmp

        puts "cp #{inDirPath}/#{file} => #{root}/public/hd/#{newFileName}"
        FileUtils::copy_file("#{inDirPath}/#{file}", "#{root}/public/hd/#{newFileName}");
      end
    end
    resource_content = JSON.pretty_generate(JSON.parse(resource.to_json)).to_s
    puts resource_content
    File.open("#{root}/public/resources.list", "w") {|f| f.write(resource_content)}
  end
end
