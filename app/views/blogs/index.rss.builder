# Author : Rajesh
# index.rss.builder
xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "LionSher"
    xml.description "LionSher"
    xml.link "http://www.lionsher.com"
    for blog in @blogs
      xml.item do
        xml.title blog.blog_title + " - " + blog.blog_name
        xml.description blog.rss_content
        xml.pubDate blog.created_at.to_s(:rfc822)
        xml.link blog.lionsher_url
        xml.guid blog.lionsher_url
      end
    end
  end
end

