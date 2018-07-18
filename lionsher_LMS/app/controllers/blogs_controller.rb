# Publish interviews
# Author : Karthik
require 'fileutils'

class BlogsController < ApplicationController
  
  def index
    @blogs = Blog.find(:all, :order => "created_at DESC")
  end

 
  def show
    @blog = Blog.find(params[:id])
  end

  
  def new
    @blog = Blog.new
  end

 
  def edit
    @blog = Blog.find(params[:id])
  end

 
  def create
    folder_name = params[:folder].gsub(' ','_')
    blog_directory = "public/images/blogs/" + folder_name
    FileUtils.mkdir_p(blog_directory)
    if !(params[:image2][:filename].nil? or params[:image2][:filename].blank?)
      image2_filename = params[:image2][:filename].original_filename
      path = File.join(blog_directory, image2_filename)
      File.open(path, "wb") { |f| f.write(params[:image2][:filename].read) }
    end
    if !(params[:image3][:filename].nil? or params[:image3][:filename].blank?)
      image3_filename = params[:image3][:filename].original_filename
      path = File.join(blog_directory, image3_filename)
      File.open(path, "wb") { |f| f.write(params[:image3][:filename].read) }
    end
    if !(params[:image4][:filename].nil? or params[:image4][:filename].blank?)
      image4_filename = params[:image4][:filename].original_filename
      path = File.join(blog_directory, image4_filename)
      File.open(path, "wb") { |f| f.write(params[:image4][:filename].read) }
    end
    if !(params[:image5][:filename].nil? or params[:image5][:filename].blank?)
      image5_filename = params[:image5][:filename].original_filename
      path = File.join(blog_directory, image5_filename)
      File.open(path, "wb") { |f| f.write(params[:image5][:filename].read) }
    end
    @blog = Blog.new(params[:blog])
    @blog.folder = folder_name
    @blog.lionsher_url = "http://www.#{SITE_URL}/learningden/"+folder_name
    @blog.save
    redirect_to(@blog)
  end

  
  def update
    @blog = Blog.find(params[:id])
    blog_directory = "public/images/blogs/" + @blog.folder
    if !(params[:image2][:filename].nil? or params[:image2][:filename].blank?)
      image2_filename = params[:image2][:filename].original_filename
      path = File.join(blog_directory, image2_filename)
      File.open(path, "wb") { |f| f.write(params[:image2][:filename].read) }
    end
    if !(params[:image3][:filename].nil? or params[:image3][:filename].blank?)
      image3_filename = params[:image3][:filename].original_filename
      path = File.join(blog_directory, image3_filename)
      File.open(path, "wb") { |f| f.write(params[:image3][:filename].read) }
    end
    if !(params[:image4][:filename].nil? or params[:image4][:filename].blank?)
      image4_filename = params[:image4][:filename].original_filename
      path = File.join(blog_directory, image4_filename)
      File.open(path, "wb") { |f| f.write(params[:image4][:filename].read) }
    end
    if !(params[:image5][:filename].nil? or params[:image5][:filename].blank?)
      image5_filename = params[:image5][:filename].original_filename
      path = File.join(blog_directory, image5_filename)
      File.open(path, "wb") { |f| f.write(params[:image5][:filename].read) }
    end
    @blog.update_attributes(params[:blog])
    redirect_to(@blog)
  end

 
  def destroy
    @blog = Blog.find(params[:id])
    @blog.destroy
    redirect_to(blogs_url)
  end

  def about

  end

  def contact

  end

  def learningden
    recent_blog_id = Blog.maximum(:id)
    recent_blog = Blog.find_by_id(recent_blog_id)
    redirect_to(recent_blog.lionsher_url)
  end

end
