# Called for creating xml file while making the chart
# Author : Surupa
xml = Builder::XmlMarkup.new
xml.graph(:showValues=>'0',:showShadow=>'0',:pieRadius=>'80',:bgAlpha=>'100') do
  for item in assessment_data
    if(item[:assessment_name] == 'pass')
      xml.set(:name=>item[:assessment_name],:value=>item[:assessment_output],:color=>'4AA02C')
    elsif(item[:assessment_name] == 'completed')
      xml.set(:name=>item[:assessment_name],:value=>item[:assessment_output],:color=>'4AA02C')
    elsif(item[:assessment_name] == 'unattempted')
      xml.set(:name=>item[:assessment_name],:value=>item[:assessment_output],:color=>'FFF380')
    elsif(item[:assessment_name] == 'fail')
      xml.set(:name=>item[:assessment_name],:value=>item[:assessment_output],:color=>'F88017')
    elsif(item[:assessment_name] == 'incomplete')
      xml.set(:name=>item[:assessment_name],:value=>item[:assessment_output],:color=>'F88017')
    else
      xml.set(:name=>item[:assessment_name],:value=>item[:assessment_output],:color=>'6698FF')
    end
  end
end