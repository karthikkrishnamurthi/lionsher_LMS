# Called for creating xml file while making the chart
# Author : Surupa
xml = Builder::XmlMarkup.new
  xml.graph(:showValues=>'0',:showShadow=>'0',:pieRadius=>'80',:bgAlpha=>'100') do
    for item in course_data
      if(item[:course_name] == 'completed')
        xml.set(:name=>item[:course_name],:value=>item[:course_output],:color=>'4AA02C')
      elsif(item[:course_name] == 'incomplete')
        xml.set(:name=>item[:course_name],:value=>item[:course_output],:color=>'FFF380')
      elsif(item[:course_name] == 'unattempted')
        xml.set(:name=>item[:course_name],:value=>item[:course_output],:color=>'F88017')
      else
        xml.set(:name=>item[:course_name],:value=>item[:course_output],:color=>'6698FF')
      end
    end
  end