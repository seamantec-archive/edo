require 'zip/zipfilesystem'
require "xml"
require "hpricot"

MAIN_LIB_DIR = "./libs/instruments"
TEMP_DIR = "./scripts/temp"
WINDOWS_HELPER = "./src/com/sailing/WindowsHelper.as"
SMALL_BITMAPS_DIR = "./assets/images/smallBitmaps"
class GenerateSwcSources
  def initialize
    @swc_paths = []
    @w_helper_content = ""
    @bitmapClasses = ""
    puts `pwd`
    init_w_helper_content
    open_direcory(MAIN_LIB_DIR)
    @swc_paths.each { |y| puts y }
    unzip_all_swc
    save_w_helper_content

  end

  def init_w_helper_content
    @class_def = <<-eos
     /*
    * This is an automatic generated file. PLEASE don't modify it.
    */
    package com.sailing {


    public class WindowsHelper {
    eos
    @w_helper_content = <<-eos

       public static var generatedContent = [

    eos
  end

  def save_w_helper_content
    @w_helper_content += "]}}"

    if (File.exist?(WINDOWS_HELPER))
      File.delete(WINDOWS_HELPER)
    end

    file = File.new(WINDOWS_HELPER, File::RDWR|File::CREAT, 0777)
    file << @class_def
    file << @bitmapClasses
    file << @w_helper_content

    file.close


  end

  def open_direcory(directory_path)
    # @lib_dir = File.open_direcory(MAIN_LIB_DIR, "r")
    if (File.directory?(directory_path))
      Dir.foreach(directory_path) do |entry|
        if (entry != "." && entry != "..")
          local_file_path = "#{directory_path}/#{entry}"
          if (File.directory?(local_file_path))
            open_direcory(local_file_path)
          elsif (entry.match(/\.swc$/))
            @swc_paths << local_file_path
          end
        end
      end
    end
  end

  def unzip_all_swc
    @swc_paths.each_with_index do |swc_path, index|
      Zip::ZipFile.open(swc_path) do |zipfile|
        zipfile.each do |file|
          name = zipfile.name.match(/\w+.swc$/)
          if (file.name == "catalog.xml")
            if File.exist?("#{TEMP_DIR}/#{name}catalog.xml")
              File.delete("#{TEMP_DIR}/#{name}catalog.xml")
            end
            zipfile.extract(file, "#{TEMP_DIR}/#{name}catalog.xml")
            source = XML::Parser.file("#{TEMP_DIR}/#{name}catalog.xml")
            content = source.parse
            scripts = content.root.children.select { |x| x.name == "libraries" }[0].children.select { |y| y.name == "library" }[0].children.select { |s| s.name == "script" }
            scripts.each do |s|
              has_sailData = s.children.select { |x| x.attributes["id"] == "com.sailing:SailData" || x.attributes["id"] == "com.events:UpdateSailingDatasEvent" }.length > 0
              if (!s.attributes["name"].match("/") && has_sailData)
                add_element_to_windows_helper("#{s.attributes["name"]}", index, swc_path, name.to_s.gsub("_", " ").gsub(".swc", ""))
              end
            end
          else
            # zipfile.extract(file, "./temp/#{name}library.swf")
          end
        end
      end
    end
  end


  def add_element_to_windows_helper(klass_name, index, path, name)
    smallBitmap = nil
    if File.exist?("#{SMALL_BITMAPS_DIR}/#{klass_name}.png")
      smallBitmap = "#{klass_name}BitmapClass"
      @bitmapClasses += <<-eof
              [Embed(source="../../../assets/images/smallBitmaps/#{klass_name}.png")]
        public static var #{klass_name}BitmapClass:Class;
      eof
    end
    @w_helper_content += <<-eof
                  {controllName: '#{name}',
                    controllClass: '#{path}', klass: #{klass_name}, #{smallBitmap.nil? ? '' : 'bitmap: new ' + klass_name+'BitmapClass(),'}
                    filePath:'#{path}'} #{index != @swc_paths.length-1 ? ',' : ''}
    eof
  end

end


GenerateSwcSources.new