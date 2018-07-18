# Called for creating xml file while making the chart
# Author : Surupa
xml = Builder::XmlMarkup.new
  xml.graph(:showValues=>'0',:showShadow=>'0',:pieRadius=>'40',:bgAlpha=>'100') do
    for item in result_data
      if(item[:status] == 'correct')
        xml.set(:name=>item[:status],:value=>item[:number],:color=>'4AA02C')
      else
        xml.set(:name=>item[:status],:value=>item[:number],:color=>'F88017')
      end
    end
  end