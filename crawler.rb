require 'net/http'
require 'nokogiri'
require 'open-uri'
require 'set'

tieba_url = "http://tieba.baidu.com/f?kw=u-know%D4%CA%BA%C6&tp=0"
page_depth = 50
article_depth = 2

head_portraits = Set.new
user_signs = Set.new
content_images = Set.new

begin 
	page = Nokogiri::HTML(open(tieba_url, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.107 Safari/537.36'))
	puts "打开: " + tieba_url

	tieba_url = nil
	tieba_pagings = page.css('#frs_list_pager a')
	tieba_pagings.each do |tieba_paging|
		tieba_url = tieba_paging.attributes['href'].value if tieba_paging.children.text == '下一页'
	end
	
	#List article
	articles = page.css('.threadlist_text.threadlist_title a')
	articles.each do |article|
		article_url = article.attributes['href'].value
		sleep rand(5) + 3
		puts "打开第一页: " + "http://tieba.baidu.com" + article_url
		article_content = Nokogiri::HTML(open("http://tieba.baidu.com" + article_url, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.107 Safari/537.36'))
		begin 
			
			sleep rand(5) + 5
			puts "http://tieba.baidu.com" + article_url
			article_content = Nokogiri::HTML(open("http://tieba.baidu.com" + article_url, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.107 Safari/537.36'))

			#获取用户头像
			portraits = article_content.css('.icon_relative.j_user_card img')
			portraits.each do |portrait|
				if portrait['data-passive'].nil?
					head_portraits.add(portrait['src'].to_s)
				else
					head_portraits.add(portrait['data-passive'].to_s)
				end
			end

			#获取用户签名
			signatures = article_content.css('.j_user_sign')
			signatures.each do |signature|
				if signature.attributes['data-passive'].nil?
					puts "***" + signature.attributes['src'].to_s
					user_signs.add(signature.attributes['src'].to_s)
				else
					puts "***" + signature.attributes['data-passive'].value.to_s
					user_signs.add(signature.attributes['data-passive'].value.to_s)
				end
			end

			#获取帖子图片
			pics = article_content.css('div[id^=post_content] img')
			pics.each do |pic|
				content_images.add(pic.attributes['src'].value.to_s) if ! pic.attributes['src'].value.include? "static.tieba.baidu.com"
			end

			article_url = nil
			#帖子下一页
			pagings = article_content.css('.l_pager.pager_theme_3 a')
			pagings.each do |paging|
				article_url = paging.attributes['href'].value if paging.children.text == '下一页'
			end

			break if article_url.nil? or ( article_depth != -1 and article_url.end_with? "pn=" + article_depth.to_s )

		end while !article_url.nil?
	end
	break
	puts "===================================================="
	puts tieba_url + "         " + page_depth.to_s
	puts tieba_url.end_with? "pn=" + page_depth.to_s
	puts "===================================================="
	break if tieba_url.nil? or ( page_depth != -1 and tieba_url.end_with? "pn=" + page_depth.to_s )

end while !tieba_url.nil?

puts "start to write files...."
puts head_portraits.inspect

working_directory = File.expand_path(File.dirname(File.dirname(__FILE__)))
head_portraits.each do |head_protrait|
	File.open(working_directory + "/head_protraits", 'a') { |file| file.write(head_protrait.to_s + "\n") }
end

user_signs.each do |user_sign|
	File.open(working_directory + "/user_signs", 'a') { |file| file.write(user_sign.to_s + "\n") }
end

content_images.each do |content_image|
	File.open(working_directory + "/content_images", 'a') { |file| file.write(content_image.to_s + "\n") }
end

puts "successful..."
