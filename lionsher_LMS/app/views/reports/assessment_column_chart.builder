# Called for creating xml file while making the chart
# Author : Surupa
xml = Builder::XmlMarkup.new
xml.graph(:showValues=>'1', :palette=>'1', :xAxisName=>'Scores', :yAxisName=>'Number of Learners', :yAxisValuesStep=>'2', :adjustDiv=>'0', :canvasBorderThickness=>'0', :canvasBorderColor=>'cccccc', :showColumnShadow=>'0', :formatNumber=>'0') do
  @chart_learners.each do |output|
    output.each do |key,value|
      xml.set(:name=> key, :value => value, :color=>'6698FF')
    end
  end  
end