require 'Thread'
require 'securerandom'
require 'net/http'
require 'open-uri'
require 'fileutils'

@working_directory = File.expand_path(File.dirname(File.dirname(__FILE__)))
FileUtils.mkdir_p @working_directory + '/images/user_signs'
FileUtils.mkdir_p @working_directory + '/images/content_images'
FileUtils.mkdir_p @working_directory + '/images/head_protraits'

def download(image_url)

  suffix = "." + image_url[/jpeg\?|jpg\?|gif\?|png\?/].gsub("?", "") or ""

  image_name = SecureRandom.hex(32) + suffix
  puts image_name + "  URL: #{image_url}"

  File.open("#{@working_directory}/images/user_signs/#{image_name}", "w") do |output|
    open(image_url) do | input |
      output << input.read
    end
  end
end

system 'echo start to downloading...'
system 'echo images will be saved to #{@working_directory}/images'

system ("wget " "-i " "#{@working_directory}/user_signs " "--directory-prefix=#{@working_directory}/images/user_signs")
system ("wget " "-i " "#{@working_directory}/head_protraits " "--directory-prefix=#{@working_directory}/images/head_protraits")
system ("wget " "-i " "#{@working_directory}/content_images " "--directory-prefix=#{@working_directory}/images/content_images")

#threads = []

#File.open(@working_directory + "/user_signs", "r").each do |line|
	#怕被封IP, 暂时禁用多线程
#	puts "starting to download: #{line}....."
#	threads << Thread.new { download(line) }
#end

#File.open(@working_directory + "/head_protraits", "r").each do |line|
	#怕被封IP, 暂时禁用多线程
#	puts "starting to download: #{line}....."
#	threads << Thread.new { download(line) }
#end

#File.open(@working_directory + "/content_images", "r").each do |line|
	#怕被封IP, 暂时禁用多线程
#	puts "starting to download: #{line}....."
#	threads << Thread.new { download(line) }
#end

#threads.each { |t| t.join }