# -*- coding: utf-8 -*-

require 'fileutils'
require 'rubygems'
#author Surupa
class ParserController < ApplicationController
  before_filter :login_required

  def parse(assessment,question_bank_id,tenant_id,current_user,assessments_question_bank)
    @first_question_bank_id = question_bank_id
    docxmlpath = "public/question_banks/#{question_bank_id}/original/word/document.xml"

    # get the XML data as a string and extract information
    xml_data = File.read(docxmlpath)
    doc = REXML::Document.new(xml_data)

    # initialize variables
    @topics = 0
    @explanation = ""
    @instruction_text = ""
    @recent_pattern = ""
    @question_text = ""
    @answer_text = ""
    @direction_text = ""
    @no_of_questions_for_direction = ""
    @error_images = Array.new
    @correct_answers = Hash.new
    @question_number_to_id_map = Hash.new
    @explanation_texts = Hash.new
    @assessment_question_bank = assessments_question_bank
    @question_bank = get_question_bank(question_bank_id)
    explanation_text_pattern = /^((\s*)(<.>)*(?i)(\s*)(Explanation)()\s*(:)(\s*)(<.+?>)*)/
      
    question_bank_id = get_data_from_xml(doc,assessment,question_bank_id,tenant_id,explanation_text_pattern,current_user)
    get_correct_answers_and_explanation(@correct_answers,@explanation_texts,explanation_text_pattern)
    @question_bank.update_attribute(:no_of_questions,@question_bank.questions.length)
    if assessment.assessment_type == "single"
      assessment.update_attribute(:no_of_questions,@question_bank.no_of_questions)
    end
    unless @assessment_question_bank.nil? or @assessment_question_bank.blank?
      @assessment_question_bank.update_attribute(:question_limit,@question_bank.no_of_questions)
    end
    #    FileUtils.rm path
  end

  def get_data_from_xml(doc,assessment,question_bank_id,tenant_id,explanation_text_pattern,current_user)
    doc.elements["w:document/w:body"].each do |body_element|
      question_bank_id = extract_text_from_docx(body_element,assessment,question_bank_id,tenant_id,current_user,explanation_text_pattern)
      extract_table_content_from_docx(body_element,question_bank_id)
      unless @question_text.nil? or @question_text.blank?
        if @question_text.end_with?("<br/>")
          @question.update_attribute(:question_text, @question_text.chomp.chomp("<br/>"))
        else
          @question.update_attribute(:question_text, @question_text.chomp)
        end
      end
    end
    unless @explanation.nil? or @explanation.blank?
      @explanation = remove_unnecesary_html_tags_in_the_beginning(@explanation)
      @explanation = remove_unnecesary_nonword_chars_enclosed_in_html_tags(@explanation)
      @explanation_texts[@question_number_with_explanation] = @explanation
      @explanation = ""
    end    
    return question_bank_id
  end

  def extract_text_from_docx(body_element,assessment,question_bank_id,tenant_id,current_user,explanation_text_pattern)
    unless body_element.elements["w:r"].nil?
      text = ""
      text = concat_paragraph_content(body_element,text,question_bank_id)
      logger.info"TEXT from xml element ------------- #{text.inspect}"

      unless text.nil?
        # Pattern:
        # Q1) Q1. 1. 1) Q.1   any of these formats starts with html tag
        # encoding: UTF-8
        question_pattern = /(?i)^((\(|\s*|[Q]*|\s*<.+>)((\d+)(<\/[^>]+><.+?>)*(\)|\.))(<.*?>)*|(([Q])\.*(\d+)))(\s+)(\w|"|“|'|<b|<i|<u|‘)/
        
        #        question_pattern_old = /(?i)^((\(|\s*|[Q]*|\s*<.+>)((\d+)(\)|\.))(<\/[^>]+>)*|(([Q])\.*(\d+)))(\s+)(\w|"|“|'|<b|<i|<u|‘)/
        remove_question_pattern = /^(\(|\s*|[qQ]*|\s*<.+>)((\d+)(<\/[^>]+><.+?>)*(\)|\.))|(([qQ])\.*(\d+))(\s+)/
        
        #        remove_question_pattern_old = /^(\(|\s*|[qQ]*|\s*<.+>)((\d+)(\)|\.))|(([qQ])\.*(\d+))(\s+)/

        # Pattern should be like:
        # (a) [a] (a). [a]. a) a). a] a].  or  [1] 1]
        option_pattern = /((^|\s+|\t+)(<.+?>)*(\(|\[|\s*)[a-eA-E](\)|\])(\.?))|((^|\s+|\t+)(<.+?>)*(\[(<.+?>)*|\s*)([1-5]((<.+?>)*\])(\.?)))/

        #        option_pattern_old = /((^|\s+|\t+)(<.+?>)*(\(|\[|\s*)[a-eA-E](\)|\])(\.?))|((^|\s+|\t+)(<.+?>)*(\[|\s*)([1-5](\])(\.?)))/

        # Answer answers (case insensitive)
        correct_answers_location = /^(?i)(\s*)(<.>)?(answer|answers)(<.>)?(\s*)/

        # If in question floating type value is there, it is conflicting with correct_option_pattern.
        # So, for correct_option_pattern if '.' is there then after '.' a space and the option should
        # start with either '(' or '[', as without these operators, it will conflict with question pattern.
        # 1. (a) 1-[A] 1-(1) 1-[1]
        correct_options_pattern = /((\d+)(\s*)(\.\s+[\(|\[]|-|–)(\s*)(\(|\[)?([a-eA-E1-5])(\)|\])?)(\s+|$|<.+>)/
        #          correct_options_pattern_old = /(\d+)(\s*)(\.\s+[\(|\[]|-)(\s*)(\(|\[)?([a-eA-E1-5])(\)|\])?(\s+|$|<.+>)/

        direction_pattern = /^(\s*)(<.>)*(?i)(Direction|Directions)([^:]*)(:)/
        direction_from_to_pattern = /(\D*)(<.+?>)*(\d+)(\s*)(<.+?>)*(to|and|&|-)*(\s*)(<.+?>)*(\d+)*(\s*)(<.+?>)*(,|:|-|)*(\s*)/
        
        # direction_from_to_pattern_old = /(\D*)(\d+)(\s*)(to|and|&|-)(\s*)(\d+)(\s*)(,|:|-|)*(\s*)/

        section_pattern = /^((?i)(\s*)(<.+>)*(section|part)(\s+)(\d+|[a-z]{1,2})(\s*)(:*)(\s*))(.+)/
        extract_info_from_section_pattern = /(?i)(\(*)(\s*)((\d+)(\s*)([a-z]+))(\s*)(\)*)/

        #        instruction_pattern = /^(\s*)(?i)([a-z]+\s*)*(instructions)(\s*)(.)*/
        #        marks_pattern = /^(\(|\s*|[qQ]*|\s*<.+>)((\d+)(\)|\.))|(([qQ])\.*(\d+))(\s+)(\w)/

        #          There are 3 scenarios for direction. They are:
        #          1. Direction from question 24 to 27, next direction appears before question 28.
        #          2. Direction from question 24 to 27, next direction appears before question 27.(wrong scenario, but have to handle. Whichever appears first)
        #          3. Direction from question 24 to 27, next direction appears after question 35. That means question 28 to 35 don't have any direction.

        logger.info"@recent_pattern #{@recent_pattern.inspect}"
        if section_pattern.match(text)
          question_bank_id = get_section_names_from_docx(text,section_pattern,extract_info_from_section_pattern,assessment,question_bank_id,current_user)
        elsif direction_pattern.match(text)
          get_direction_from_docx(text,direction_pattern,direction_from_to_pattern,question_bank_id,tenant_id)
        elsif correct_answers_location.match(text)
          @recent_pattern = "correct_answers"
        elsif @recent_pattern == "correct_answers" or (@recent_pattern == "explanation" and correct_options_pattern.match(text)) and !question_pattern.match(text)
          text.scan(correct_options_pattern).length.times do |i|
            question_number,correct_option = text.scan(correct_options_pattern)[i][1],text.scan(correct_options_pattern)[i][6]
            @correct_answers[question_number] = correct_option
          end
          get_explanation_from_xml(text,correct_options_pattern)
          #Finding out whether it is a @question or an answer
        elsif question_pattern.match(text) and @recent_pattern != "question" and (text.index(correct_options_pattern) != 0) and text.scan(question_pattern).length == 1
          get_question_text_from_docx(text,remove_question_pattern,question_bank_id,tenant_id)
        elsif option_pattern.match(text) and (@recent_pattern == "question" or @recent_pattern == "answer")
          get_answer_text_from_docx(text,option_pattern,question_bank_id,tenant_id)
        elsif @recent_pattern == "question" and !text.nil? and !option_pattern.match(text)
          @question_text = @question_text + text
        elsif @recent_pattern == "answer" and !text.nil? and (!option_pattern.match(text) or !section_pattern.match(text) or !correct_answers_location.match(text) or !question_pattern.match(text) or !direction_pattern.match(text))
          @answer_text = @answer_text + text
          @answer_text = remove_unnecesary_nonword_chars_enclosed_in_html_tags(@answer_text)
          if @answer_text.end_with?("<br/>")
            @answer.update_attribute(:answer_text,@answer_text.chomp.chomp("<br/>"))
          else
            @answer.update_attribute(:answer_text,@answer_text.chomp)
          end
        elsif @recent_pattern == "explanation" and !correct_options_pattern.match(text)
          @explanation = @explanation + text
          @explanation_texts[@question_number_with_explanation] = @explanation        
        elsif @recent_pattern == "direction" and !question_pattern.match(text)
          @direction_text = @direction_text + text
          @direction_obj.update_attribute(:direction_text, @direction_text)
        end
      end
    end
    get_correct_answers_and_explanation(@correct_answers,@explanation_texts,explanation_text_pattern)
    return question_bank_id
  end

  def get_explanation_from_xml(text,correct_options_pattern)
    logger.info"correct_options_pattern #{correct_options_pattern.inspect}"
    if text.scan(correct_options_pattern).length > 1
      # control comes here when we have more that one explanation in one line
      # If we split text with correct option pattern, we will get one array.
      text.split(correct_options_pattern).each do |part|
        if part.match(correct_options_pattern)          
          # location contains the index of matched pattern, e.g. "10. (d)" or "11. (a)" etc.
          # Always the next location contains the question number like 10 or 11
          # And the 9th location after matched pattern contains the explanation text
          location = text.split(correct_options_pattern).index(part)
          unless text.split(correct_options_pattern)[location + 8].nil? or text.split(correct_options_pattern)[location + 8].blank?
            @question_number_with_explanation = text.split(correct_options_pattern)[location + 1]
            @explanation = text.split(correct_options_pattern)[location + 8]
            @explanation = remove_unnecesary_html_tags_in_the_beginning(@explanation)
            @explanation = remove_unnecesary_nonword_chars_enclosed_in_html_tags(@explanation)
            if !correct_options_pattern.match(@explanation) and @explanation.strip != ""
              @explanation_texts[@question_number_with_explanation] = @explanation
              @recent_pattern = "explanation"
            end
          end
          @explanation = ""
        end
      end
    else
      if correct_options_pattern.match(text)
        unless @explanation.nil? or @explanation.blank?
          @explanation = remove_unnecesary_html_tags_in_the_beginning(@explanation)
          @explanation = remove_unnecesary_nonword_chars_enclosed_in_html_tags(@explanation)
          @explanation_texts[@question_number_with_explanation] = @explanation
          @explanation = ""
        end
        answer_option_to_remove = text.scan(correct_options_pattern)[0][0]
        @question_number_with_explanation = answer_option_to_remove.scan(correct_options_pattern)[0][1]
        text.slice!(answer_option_to_remove)
        explanation = text
        if !correct_options_pattern.match(explanation) and explanation.strip != ""
          @explanation = explanation
          @explanation_texts[@question_number_with_explanation] = explanation
          @recent_pattern = "explanation"
        end
      end
    end
  end

  def remove_unnecessary_spaces_at_the_end_of_text_and_create_answer(question_bank_id,tenant_id)
    if @answer_text.end_with? "<br/>"
      @answer = create_answer(@answer_text.chomp.chomp("<br/>"),@question.id,tenant_id,question_bank_id,"wrong")
    else
      @answer = create_answer(@answer_text.chomp,@question.id,tenant_id,question_bank_id,"wrong")
    end
  end

  def get_section_names_from_docx(text,section_pattern,extract_info_from_section_pattern,assessment,question_bank_id,current_user)
    section_tag = text.scan(section_pattern)[0][0]
    text.slice!(section_tag)
    section_name = text
    logger.info"SECTION NAME before removing section info #{section_name.inspect}"
    if extract_info_from_section_pattern.match(section_name)
      section_infos = Array.new
      no_of_info = section_name.scan(extract_info_from_section_pattern).length
      section_name.scan(extract_info_from_section_pattern).length.times do |i|
        info_number,info_name = section_name.scan(extract_info_from_section_pattern)[i][3],section_name.scan(extract_info_from_section_pattern)[i][5]
        section_infos[i] = section_name.scan(extract_info_from_section_pattern)[i][2]
      end
      no_of_info.times do |i|
        section_name.slice!(section_infos[i])
      end
    end
    logger.info"SECTION NAME after removing section info #{section_name.inspect}"
    if section_name.strip.end_with? "<br/>"
      section_name = section_name.chomp.chomp("<br/>").strip
      section_name.slice!(/(<\/[^>]+>)|(<\w[^>]\/>)/)      
    end
    logger.info"SECTION NAME before removing <br/> and html tags #{section_name.inspect}"
    if section_name.strip.end_with? ","
      section_name = section_name.chomp(",").strip
    end
    if section_name.strip.end_with? ":"
      section_name = section_name.gsub(":","")
    end
    logger.info"SECTION NAME final #{section_name.inspect}"
    if @topics == 0
      if section_name.strip == ""
        @question_bank.update_attribute(:name,"topic "+(@topics + 1).to_s)
      else
        @question_bank.update_attribute(:name,section_name)
      end
      @topics = @topics + 1
    else
      @question_bank.update_attribute(:no_of_questions,@question_bank.questions.length)
      unless @assessment_question_bank.nil? or @assessment_question_bank.blank?
        @assessment_question_bank.update_attribute(:question_limit,@question_bank.no_of_questions)
      end      
      @question_bank = QuestionBank.new
      if section_name.strip == ""
        @question_bank.name = "topic "+(@topics + 1).to_s
      else
        @question_bank.name = section_name
      end
      @question_bank.user_id = current_user.id
      @question_bank.tenant_id = current_user.tenant_id
      @question_bank.save      
      assessment_controller_obj = AssessmentsController.new
      @assessment_question_bank = assessment_controller_obj.create_and_save_assessment_question_bank(assessment.id,@question_bank.id,@question_bank.no_of_questions)      
      assessment.update_attribute(:assessment_type,"multiple")
      @topics = @topics + 1
    end
    return @question_bank.id
  end

  def get_direction_from_docx(text,direction_pattern,direction_from_to_pattern,question_bank_id,tenant_id)
    direction = direction_pattern.match(text)[0]
    text.slice!(direction)
    logger.info"TEXT #{text.inspect}"
    @direction_text = text
    logger.info"DIRECTION #{direction.inspect}"
    logger.info"DIRECTION TEXT #{@direction_text.inspect}"
    if !direction_from_to_pattern.match(direction).nil? and direction_from_to_pattern.match(direction)
      # if direction for x to y, then in regex 6th match is y and 2nd match is x
      # So number of questions will be (y - x) + 1      
      @no_of_questions_for_direction = (direction_from_to_pattern.match(direction)[9].to_i - direction_from_to_pattern.match(direction)[3].to_i) + 1
    elsif direction_from_to_pattern.match(@direction_text)
      @no_of_questions_for_direction = (direction_from_to_pattern.match(@direction_text)[9].to_i - direction_from_to_pattern.match(@direction_text)[3].to_i) + 1
      @direction_text = @direction_text.gsub(direction_from_to_pattern.match(@direction_text)[0],"")
    else
      @no_of_questions_for_direction = ""
    end
    @direction_text = remove_unnecesary_html_tags_in_the_beginning(@direction_text)
    @direction_obj = create_direction(@direction_text,question_bank_id,tenant_id)
    @recent_pattern = "direction"
  end

  def get_question_text_from_docx(text,remove_question_pattern,question_bank_id,tenant_id)
    unless @question_text.nil? or @question_text.blank?
      if @question_text.end_with?("<br/>")
        @question.update_attribute(:question_text, @question_text.chomp.chomp("<br/>"))
      else
        @question.update_attribute(:question_text, @question_text.chomp)
      end
      @question_text = ""
    end
    question_number = remove_question_pattern.match(text)[0]
    text.slice!(question_number)
    @question_text = text
    @question_text = remove_unnecesary_html_tags_in_the_beginning(@question_text)
    logger.info"QUESTION TEXT <> #{@question_text.inspect}"
    if @direction_text.strip == "" then
      @question = create_question(@question_text,question_bank_id,tenant_id,"MCQ","","","")
    elsif @no_of_questions_for_direction == "" then
      # Control comes here when direction is there but no duration of questions mentioned
      @question = create_question(@question_text,question_bank_id,tenant_id,"MCQ","",@direction_obj.id,"")
    elsif @no_of_questions_for_direction > 0 then
      # Control comes here when direction with duration of question mentioned
      @question = create_question(@question_text,question_bank_id,tenant_id,"MCQ","",@direction_obj.id,"")
      @no_of_questions_for_direction = @no_of_questions_for_direction - 1
    else
      @question = create_question(@question_text,question_bank_id,tenant_id,"MCQ","","","")
    end
    @recent_pattern = "question"
    logger.info"Question number: #{question_number.inspect}"
    @question_number_to_id_map[question_number.scan(/\d+/)[0]] = @question.id
  end

  def get_answer_text_from_docx(text,option_pattern,question_bank_id,tenant_id)
    @answer_text = ""
    text.split(' ').each do |option|
      if option_pattern.match(option)
        unless @answer_text.nil? or @answer_text.blank?
          @answer_text = remove_unnecesary_html_tags_in_the_beginning(@answer_text)
          logger.info"ANSWER TEXT---- #{@answer_text.inspect}"
          remove_unnecessary_spaces_at_the_end_of_text_and_create_answer(question_bank_id,tenant_id)
          @answer_text = ""
        end
        @recent_pattern = "answer"
        answer_option = option_pattern.match(option)[0]
        option.slice!(answer_option)
        @answer_text = option
        logger.info"Answer option #{answer_option.inspect}"
      elsif @recent_pattern == "answer" and !option_pattern.match(option)
        @answer_text = @answer_text + " " + option
      end
    end
    @answer_text = remove_unnecesary_html_tags_in_the_beginning(@answer_text)
    logger.info"ANSWER TEXT outside loop---- #{@answer_text.inspect}"
    remove_unnecessary_spaces_at_the_end_of_text_and_create_answer(question_bank_id,tenant_id)
  end

  def extract_table_content_from_docx(body_element,question_bank_id)
    unless body_element.elements["w:tr"].nil?
      table_content = get_table_content_in_doc(body_element,question_bank_id)
      logger.info"TABLE CONTENT #{table_content.inspect}"
      if @recent_pattern == "question"
        unless @question_text.nil?
          @question_text = @question_text + table_content
          logger.info"TEXT after extracting table #{@question_text.inspect}"
        end
      elsif @recent_pattern == "direction"
        unless @direction_text.nil?
          @direction_text = @direction_text + table_content
          logger.info"TEXT after extracting table #{@direction_text.inspect}"
        end
      elsif @recent_pattern == "explanation"
        unless @explanation.nil?
          @explanation = @explanation + table_content
          logger.info"TEXT after extracting table #{@explanation.inspect}"
        end
      end
    end
  end

  def get_correct_answers_and_explanation(correct_answers,explanation_hash,explanation_text_pattern)
    unless correct_answers.nil? or correct_answers.blank?
      @question_number_to_id_map.each { |question_number,question_id|
        question = get_question(question_id)
        unless correct_answers[question_number].nil?
          if correct_answers.fetch(question_number).to_i.zero?
            # to find the correct answer's location in below formula, I am fetching the
            # correct option from correct_answers hash and find out the hex number. Then
            # I am subtracting 10, as .hex returns 10 for "A"/"a", 11 for "B"/"b" and so on.
            correct_option_location = (correct_answers.fetch(question_number).hex) - 10
          else
            # If in hash the hash values are integer and not alphabets like "A","B",etc, then
            # there is no need of getting the hex value and subtracting 10.
            correct_option_location = (correct_answers.fetch(question_number).to_i) - 1
          end
          logger.info"correct_option_location #{correct_option_location.inspect}"
          answer_object = question.answers[correct_option_location]
          unless answer_object.nil?
            answer_object.update_attribute("answer_status","correct")
          end
          if @recent_pattern != "explanation"
            @question_number_to_id_map.delete(question_number)
          end
        end
        unless explanation_hash[question_number].nil?
          explanation_text = explanation_hash.fetch(question_number)
          explanation_text = remove_unnecesary_html_tags_in_the_beginning(explanation_text)
          if explanation_text_pattern.match(explanation_text)
            explanation_tag = explanation_text_pattern.match(explanation_text)[0]
            explanation_text.slice!(explanation_tag)
          end
          if explanation_text.end_with? "<br/>"
            explanation_text = explanation_text.chomp.chomp("<br/>")
          elsif explanation_text.end_with? "*"
            explanation_text = explanation_text.chomp.chomp("*")
          else
            explanation_text = explanation_text.chomp
          end
          unless explanation_text.strip.nil? or explanation_text.strip.blank?
            logger.info"question_number in explanation hash #{question_number.inspect}"
            logger.info"explanation text in explanation hash #{explanation_text.inspect}"
            question.update_attribute("explanation",explanation_text)
          end
        end
      }
      if @recent_pattern != "explanation"
        correct_answers.clear
      end
      #        @question_number_to_id_map.clear
      #        @recent_pattern = ""
    end
  end

  def remove_unnecesary_html_tags_in_the_beginning(text)
    # If text starts with <br/> or </b> or </i> or </u> etc., it removes them
    if text.index(/(<\/[^>]+>)|(<\w[^>]\/>)/) == 0
      text.slice!(/(<\/[^>]+>)|(<\w[^>]\/>)/)
      logger.info"Text after removing strating html tag #{text.inspect}"
    end
    return text
  end

  def remove_unnecesary_nonword_chars_enclosed_in_html_tags(text)
    # If in text there is something like <b>********</b><br/> then we should remove them
    unnecesary_chars_enclosed_in_html_pattern = /(<\w[^>]\/>)(<\w>)*(\W+)(<\/[^>]+>)*(<\w[^>]\/>)/
    if text.match(unnecesary_chars_enclosed_in_html_pattern)
      remove_chars = text.match(unnecesary_chars_enclosed_in_html_pattern)[0]
      text = text.gsub(remove_chars,"")
    end
    return text
  end

  def insert_special_symbol(text,file,special_char_pattern)
    unless text.nil? or text.blank?
      last_line = ""
      i = 0
      j = 1
      if text.include? "error_image"
        text_array = text.split("error_image")
        no_of_images = text_array.length - 1
        logger.info"text_array before inserting spcl symbols #{text_array.inspect}"
        while (line = file.gets) and (j <= no_of_images)
          option = line.strip
          if (i < text_array.length) and special_char_pattern.match(option) and text_array[i].strip.include? last_line.strip
            logger.info"last_line #{last_line.inspect}"
            logger.info"i #{i.inspect}"
            logger.info"SYMBOL to be inserted #{special_char_pattern.match(option)[0].inspect}"
            text_array.insert(i + 1,special_char_pattern.match(option)[0])
            i = i + 2
            j = j + 1
          else
            unless option.nil? or option.blank? or option.strip.split(" ").join("") == ""
              logger.info"option in else #{option.inspect}"
              last_line = option
            end
          end
        end
        text = text_array.join(" ")
      end
    end
    return text
  end

  def concat_paragraph_content(xml_element,text,question_bank_id)
    xml_element.elements.each("w:r") do |run_element|
      unless run_element.elements["w:tab"].nil?
        #        logger.info"TAB not nil before wt"
        text = text + " "
      end
      
      #      run_element.elements.each("w:tab") do |text_element|
      #        text = text + " "
      #      end

      unless run_element.elements["w:rPr/w:vertAlign"].nil?
        if run_element.elements["w:rPr/w:vertAlign"].attributes["w:val"] == "superscript"
          property = "superscript"
        elsif run_element.elements["w:rPr/w:vertAlign"].attributes["w:val"] == "subscript"
          property = "subscript"
        end
      end

      unless run_element.elements["w:rPr/w:b"].nil?
        property = "bold"
      end

      unless run_element.elements["w:rPr/w:i"].nil?
        property = "italic"
      end

      unless run_element.elements["w:rPr/w:u"].nil?
        property = "underline"
      end

      run_element.elements.each("w:t") do |text_element|
        unless run_element.elements["w:tab"].nil?
          #          logger.info"TAB not nil before"
          text = text + " "
        end
        check_if_blank = text_element.text.strip.split(' ').join('')

        if property == "superscript" and check_if_blank != ""
          if !(text_element.text.lstrip!).nil?
            text = text + " <sup>" + text_element.text + "</sup>"
          elsif !(text_element.text.rstrip!).nil?
            text = text + "<sup>" + text_element.text + "</sup> "
          else
            text = text + "<sup>" + text_element.text + "</sup>"
          end
        elsif property == "subscript" and check_if_blank != ""
          if !(text_element.text.lstrip!).nil?
            text = text + " <sub>" + text_element.text + "</sub>"
          elsif !(text_element.text.rstrip!).nil?
            text = text + "<sub>" + text_element.text + "</sub> "
          else
            text = text + "<sub>" + text_element.text + "</sub>"
          end
        elsif property == "bold" and check_if_blank != ""
          if !(text_element.text.lstrip!).nil?
            text = text + " <b>" + text_element.text + "</b>"
          elsif !(text_element.text.rstrip!).nil?
            text = text + "<b>" + text_element.text + "</b> "
          else
            text = text + "<b>" + text_element.text + "</b>"
          end
        elsif property == "italic" and check_if_blank != ""
          if !(text_element.text.lstrip!).nil?
            text = text + " <i>" + text_element.text + "</i>"
          elsif !(text_element.text.rstrip!).nil?
            text = text + "<i>" + text_element.text + "</i> "
          else
            text = text + "<i>" + text_element.text + "</i>"
          end
        elsif property == "underline" and check_if_blank != ""
          if !(text_element.text.lstrip!).nil?
            text = text + " <u>" + text_element.text + "</u>"
          elsif !(text_element.text.rstrip!).nil?
            text = text + "<u>" + text_element.text + "</u> "
          else
            text = text + "<u>" + text_element.text + "</u>"
          end
        else
          #          if text_element.attributes["xml:space"]
          #            text = text + " " + text_element.text
          #          else
          text = text + text_element.text
          #          end
        end
        unless run_element.elements["w:tab"].nil?
          #          logger.info"TAB not nil after"
          text = text + " "
        end
      end
      #      logger.info"TEXT AFTER W:T LOOP #{text.inspect}"
      #      unless run_element.elements["w:tab"].nil?
      #        text = text + " "
      #      end
      #      if @recent_pattern == "question" or @recent_pattern == "answer"
      text = extract_inline_images_for_doc(run_element,text,@first_question_bank_id)
      
      #      end
    end
    #    if @recent_pattern == "question" or @recent_pattern == "answer"
    text = extract_image_within_para(xml_element,text,@first_question_bank_id)
    #    end
    unless text.nil?
      text = text + "<br/>"
    end

    return text
    #      unless text.nil?
    #        logger.info"#{text.inspect}"
    #      end
  end

  def extract_inline_images_for_doc(run_element,text,question_bank_id)
    # for extracting inline images within para
    # points = pixels * 72 / 96
    # pixels = (points * 96) / 72
    run_element.elements.each("w:object/v:shape") do |shape_element|
      dimensions = shape_element.attributes["style"].split(";")
      view_width = (((dimensions[0].gsub("width:","").gsub("pt","").to_f)*96)/72).round
      view_height = (((dimensions[1].gsub("height:","").gsub("pt","").to_f)*96)/72).round  
      if view_height < 14
        view_height_ratio = 14/view_height.to_f
        view_height = 14
        view_width = (view_height_ratio * view_width).round
      end
      shape_element.elements.each("v:imagedata") do |inline_image_element|
        inline_image_id = inline_image_element.attributes["r:id"]
        docrelpath = "public/question_banks/#{question_bank_id}/original/word/_rels/document.xml.rels"
        rel_data = File.read(docrelpath)
        docrel = REXML::Document.new(rel_data)
        docrel.elements.each("Relationships/Relationship") do |rel_xml_element|
          if rel_xml_element.attributes["Id"] == inline_image_id
            inline_image_path = rel_xml_element.attributes["Target"]
            inline_image_path = "public/question_banks/#{question_bank_id}/original/word/" + inline_image_path
            image_extension = File.extname(inline_image_path)
            basename = File.basename(inline_image_path)
            image_name = basename.chomp(image_extension)
            system "identify #{inline_image_path} > public/question_banks/#{question_bank_id}/original/word/media/image_info.txt"
            image_information = File.read("public/question_banks/#{question_bank_id}/original/word/media/image_info.txt")
            unless image_information.split(" ")[2].nil? or image_information.split(" ")[2].blank? or image_information.include? "Error" or image_information.include? "error"
              original_image_height = image_information.split(" ")[2].split("x")[1]
            end
            png_image_path = "public/question_banks/#{question_bank_id}/resized/#{image_name}.png"
            #parser_obj = ParserController.new
            #parser_obj.delay.convert_and_resize_image(inline_image_path,png_image_path,width,height)
            unless image_information.split(" ")[2].nil? or image_information.split(" ")[2].blank? or image_information.include? "Error" or image_information.include? "error"
              ratio = (view_height/original_image_height.to_i)
              density = ratio * 200
            else
              ratio = 0
            end
            if ratio < 1
              system "convert -density 288 #{inline_image_path}['#{view_width}x#{view_height}'] #{png_image_path} 2> public/question_banks/#{question_bank_id}/resized/error.txt"
            else
              system "convert -density #{density} #{inline_image_path}['#{view_width}x#{view_height}'] #{png_image_path} 2> public/question_banks/#{question_bank_id}/resized/error.txt"
            end
            system "cat " + "public/question_banks/#{question_bank_id}/resized/error.txt >> " + "public/question_banks/#{question_bank_id}/resized/coversion_error.txt"
            if File.zero?("public/question_banks/#{question_bank_id}/resized/error.txt")
              inline_image_path = png_image_path
            else
              inline_image_path = "?"
            end
            if inline_image_path != "?"
              inline_image_path = "/question_banks/#{question_bank_id}/resized/#{image_name}.png"
              text = text + "<img src='#{inline_image_path}' style='vertical-align:middle;'/>" + " "
            else
              text = text + "<img src='' alt='Image missing' style='color: red;vertical-align:middle;'/>" + " "
            end
          end
        end
      end
    end
    return text
  end

  def convert_and_resize_image(inline_image_path,png_image_path,width,height)
    system "convert -density 288 #{inline_image_path}['#{width}x#{height}'] #{png_image_path}"
    #puts "delayed job"
  end

  def extract_image_within_para(xml_element,text,question_bank_id)
    # for extracting images within para
    # EMU = pixel * 914400 / 96 (EMU is English Metric Units, where 96 is monitor resolution)
    # pixel = (EMU * 96) / 914400
    # length (x axis --- a:xfrm cx)
    # width or height (y axis --- a:xfrm cy)
    xml_element.elements.each("w:r/w:drawing/wp:anchor/a:graphic/a:graphicData/pic:pic") do |pic_element|
      pic_element.elements.each("pic:spPr/a:xfrm/a:ext") do |xfrm_element|
        width = ((xfrm_element.attributes["cx"].to_f * 96)/914400).round
        height = ((xfrm_element.attributes["cy"].to_f * 96)/914400).round
        pic_element.elements.each("pic:blipFill/a:blip") do |image_element|
          image_id = image_element.attributes["r:embed"]
          # path of document's relationship file
          docrelpath = "public/question_banks/#{question_bank_id}/original/word/_rels/document.xml.rels"
          rel_data = File.read(docrelpath)
          docrel = REXML::Document.new(rel_data)
          docrel.elements.each("Relationships/Relationship") do |rel_xml_element|
            if rel_xml_element.attributes["Id"] == image_id
              image_path = rel_xml_element.attributes["Target"]
              image_name_with_ext = image_path.split("media/")[1]
              image_extension = File.extname(image_name_with_ext)
              basename = File.basename(image_path)
              image_name = basename.chomp(image_extension)
              image_path = "public/question_banks/#{question_bank_id}/original/word/media/#{image_name}#{image_extension}"
              assets_images_path = "public/question_banks/#{question_bank_id}/resized/#{image_name}.png"
              #parser_obj = ParserController.new
              #parser_obj.delay.convert_and_resize_image(image_path,assets_images_path,width,height)
              system "convert #{image_path}['#{width}x#{height}'] #{assets_images_path}"
              image_path = "/question_banks/#{question_bank_id}/resized/#{image_name}.png"
              text = text + "<img src='#{image_path}' style='vertical-align:middle;'/>"
            end
          end
        end
      end
    end
    return text
  end

  def get_table_content_in_doc(body_element,question_bank_id)
    table_content = "<table style='border: 1px solid black; border-collapse: collapse;'>"
    body_element.elements.each("w:tr") do |table_row_element|
      table_content = table_content + "<tr style='border-bottom: 1px solid black;'>"
      table_row_element.elements.each("w:tc") do |table_column_element|
        unless table_column_element.elements["w:tcPr/w:gridSpan"].nil?
          table_content = table_content + "<td style='color: black; font-size:12px; padding:3px; border-right: 1px solid black;' colspan='#{table_column_element.elements["w:tcPr/w:gridSpan"].attributes["w:val"]}'>"
        else
          table_content = table_content + "<td style='color: black; font-size:12px; padding:3px; border-right: 1px solid black;'>"
        end
        table_column_element.elements.each("w:p/w:r") do |column_content|
          unless column_content.elements["w:rPr/w:b"].nil?
            property = "bold"
          end
          unless column_content.elements["w:rPr/w:i"].nil?
            property = "italic"
          end
          unless column_content.elements["w:rPr/w:u"].nil?
            property = "underline"
          end
          unless column_content.elements["w:t"].nil?
            if property == "superscript"
              table_content = table_content + "<sup>" + column_content.elements["w:t"].text + "</sup>"
            elsif property == "subscript"
              table_content = table_content + "<sub>" + column_content.elements["w:t"].text + "</sub>"
            elsif property == "bold"
              table_content = table_content + "<b>" + column_content.elements["w:t"].text + "</b>"
            elsif property == "italic"
              table_content = table_content + "<i>" + column_content.elements["w:t"].text + "</i>"
            elsif property == "underline"
              table_content = table_content + "<u>" + column_content.elements["w:t"].text + "</u>"
            else
              table_content = table_content + column_content.elements["w:t"].text
            end
          end
          unless column_content.elements["w:object/v:shape"].nil?
            table_content = extract_inline_images_for_doc(column_content,table_content,@first_question_bank_id)
          end
        end
        table_content = table_content + "</td>"
      end
      table_content = table_content + "</tr>"
    end
    table_content = table_content + "</table>"
  end

  # Author: SUrupa
  # Below code is for parsing excel file for questions
  def parse_excel_file(subtopic_id,topic_id,question_bank_id,excel_file,tenant_id)
    import = Import.new(excel_file)
    if import.save!
      mime = (MIME::Types.type_for(import.excel.path)[0])
      mime_obj = mime.extensions[0]
      #do not process further if the uploaded file is other than xls,xlsx
      if (!mime_obj.nil? and !mime_obj.blank?) and (mime_obj.include? "xls" or mime_obj.include? "xlsx" or mime_obj.include? "ods") then
        @roo = create_roo_instance(import.excel.path,mime_obj)
        process_the_excel_file(import.id,subtopic_id,topic_id,question_bank_id,tenant_id)
      else
        flash[:notice] = 'Upload only document or excel file'
      end
      delete_excel(import.excel.path)
      import.destroy
    else
      flash[:notice] = 'Excel data import failed'
    end
  end

  #create roo object based on the mime_type. check http://roo.rubyforge.org/rdoc/index.html
  def create_roo_instance(imported_file_path,mime_obj)
    case(mime_obj)
    when 'xlsx' then
      roo = Excelx.new(imported_file_path)
    when 'ods' then
      roo = Openoffice.new(imported_file_path)
    when 'xls' then
      roo = Excel.new(imported_file_path)
    else
      roo = "Upload correct file format"
    end
    return roo
  end

  def process_the_excel_file(id,subtopic_id,topic_id,question_bank_id,tenant_id)
    import = Import.find(id)
    unless @roo == "Upload correct excel format" then
      lines = parse_excel_file_roo(@roo)
      if lines.size > 0
        import.processed = lines.size
        @passage_id = ""
        for i in 0..(lines.length-1)
          question_types = ["MCQ","MAQ","SA","FIB"]
          unless lines[i][0].nil?
            lines[i][0] = lines[i][0].strip.split(' ').join('').upcase
          else
            lines[i][0] = ""
          end
          if question_types.include?(lines[i][0])
            case(lines[i][0])
            when "MAQ"
              maq_correct_ans_column = 7
              fill_question_related_tables_for_maq(lines[i],lines[i][1],lines[i][0],maq_correct_ans_column,2,6,subtopic_id,topic_id,question_bank_id,tenant_id,@passage_id)              
            else
              fill_question_related_tables(lines[i],lines[i][1],lines[i][0],lines[i][7],2,6,subtopic_id,topic_id,question_bank_id,tenant_id,@passage_id)
            end
          elsif ((!lines[i+1].nil? and (question_types.include?(lines[i+1][1])) or lines[i][0].upcase == "PTQ"))
            if (!lines[i][0].nil? and lines[i][0].upcase == "PTQ")
              @passage_id = fill_passage_table_for_question(lines[i],question_bank_id,tenant_id)
            end
            fill_question_related_tables(lines[i+1],lines[i+1][2],lines[i+1][1],lines[i+1][8],3,7,subtopic_id,topic_id,question_bank_id,tenant_id,@passage_id)
          end
        end
      else
        flash[:notice] = "Excel data processing failed"
      end
    else
      flash[:notice] = "Upload correct file format"
    end
  end

  #parse the excel file directly using roo.
  def parse_excel_file_roo(roo_obj)
    roo_obj.default_sheet = roo_obj.sheets.first
    lines = Array.new
    (1..roo_obj.last_row).each do |r|
      lines << roo_obj.row(r)
    end
    return lines
  end

  def fill_passage_table_for_question(csv_row,question_bank_id,tenant_id)
    passage = create_passage(csv_row[1],question_bank_id,tenant_id)
    return passage.id
  end

  def fill_question_related_tables(csv_row,question_text,question_type,answer_text,answer_column_start,answer_column_end,subtopic_id,topic_id,question_bank_id,tenant_id,passage_id)
    question_obj = create_question(question_text,question_bank_id,tenant_id,question_type,"","",passage_id)
    question_attribute = get_question_attribute(question_obj.id)
    for k in answer_column_start..answer_column_end
      unless csv_row[k].nil? or csv_row[k].blank?
        if (question_attribute.question_type.value == "FIB" or question_attribute.question_type.value == "SA")
          create_answer(csv_row[k],question_obj.id,tenant_id,question_bank_id,"correct")
          create_answer("fib_sa_wrong_ans",question_obj.id,tenant_id,question_bank_id,"wrong")
        else
          if csv_row[k] == answer_text
            create_answer(csv_row[k],question_obj.id,tenant_id,question_bank_id,"correct")
          else
            create_answer(csv_row[k],question_obj.id,tenant_id,question_bank_id,"wrong")
          end
        end
      end
    end
    unless csv_row[13].nil? or csv_row[13].blank?
      if topic_id.nil? or topic_id.blank?
        topic_id = create_topic(csv_row[13],question_bank_id,tenant_id)
      end
    end
    unless csv_row[14].nil? or csv_row[14].blank?
      if subtopic_id.nil? or subtopic_id.blank?
        subtopic_id = create_subtopic(csv_row[14],topic_id,question_bank_id,tenant_id)
      end
    end
    unless csv_row[15].nil? or csv_row[15].blank?
      difficulty_id = get_difficulty(csv_row[15])
    end
    question_attribute.update_attribute("topic_id",topic_id)
    question_attribute.update_attribute("subtopic_id",subtopic_id)
    question_attribute.update_attribute("difficulty_id",difficulty_id)
    reason_for_error_in_question = is_question_format_correct(question_attribute)
    unless reason_for_error_in_question.nil? or reason_for_error_in_question.blank?
      error_id = get_error(reason_for_error_in_question,tenant_id)
      question_attribute.update_attribute("error_id",error_id)
    end
    reason_for_error_in_answer = is_answer_format_correct(question_obj)
    unless reason_for_error_in_answer.nil? or reason_for_error_in_answer.blank?
      error_id = get_error(reason_for_error_in_answer,tenant_id)
      question_attribute.update_attribute("error_id",error_id)
    end
  end

  def fill_question_related_tables_for_maq(csv_row,question_text,question_type,answer_text_column,answer_column_start,answer_column_end,subtopic_id,topic_id,question_bank_id,tenant_id,passage_id)
    question_obj = create_question(question_text,question_bank_id,tenant_id,question_type,"","",passage_id)
    question_attribute = get_question_attribute(question_obj.id)
    for k in answer_column_start..answer_column_end
      unless csv_row[k].nil? or csv_row[k].blank?
        if (question_attribute.question_type.value == "FIB" or question_attribute.question_type.value == "SA")
          create_answer(csv_row[k],question_obj.id,tenant_id,question_bank_id,"correct")
          create_answer("fib_sa_wrong_ans",question_obj.id,tenant_id,question_bank_id,"wrong")
        else
          if csv_row[k] == csv_row[answer_text_column]
            create_answer(csv_row[k],question_obj.id,tenant_id,question_bank_id,"correct")
            answer_text_column = answer_text_column + 1
          else
            create_answer(csv_row[k],question_obj.id,tenant_id,question_bank_id,"wrong")
          end          
        end
      end
    end
    unless csv_row[13].nil? or csv_row[13].blank?
      if topic_id.nil? or topic_id.blank?
        topic_id = create_topic(csv_row[13],question_bank_id,tenant_id)
      end
    end
    unless csv_row[14].nil? or csv_row[14].blank?
      if subtopic_id.nil? or subtopic_id.blank?
        subtopic_id = create_subtopic(csv_row[14],topic_id,question_bank_id,tenant_id)
      end
    end
    unless csv_row[15].nil? or csv_row[15].blank?
      difficulty_id = get_difficulty(csv_row[15])
    end
    question_attribute.update_attribute("topic_id",topic_id)
    question_attribute.update_attribute("subtopic_id",subtopic_id)
    question_attribute.update_attribute("difficulty_id",difficulty_id)
    reason_for_error_in_question = is_question_format_correct(question_attribute)
    unless reason_for_error_in_question.nil? or reason_for_error_in_question.blank?
      error_id = get_error(reason_for_error_in_question,tenant_id)
      question_attribute.update_attribute("error_id",error_id)
    end
    reason_for_error_in_answer = is_answer_format_correct(question_obj)
    unless reason_for_error_in_answer.nil? or reason_for_error_in_answer.blank?
      error_id = get_error(reason_for_error_in_answer,tenant_id)
      question_attribute.update_attribute("error_id",error_id)
    end
  end

  def is_question_format_correct(question_attribute)
    if question_attribute.question.question_text.nil?
      error_string = "Question cannot be blank"
    end
    if question_attribute.question_type.value == "FIB" and !question_attribute.question.question_text.include? "___"
      error_string = "FIB should contain atleast three consecutive underscores"
    end
    return error_string
  end

  def is_answer_format_correct(question_obj)
    error_string = ""
    answers = get_answers_for_question(question_obj.id)
    correct_ans_found = 0
    no_options_given = 0

    unless answers.nil? or answers.blank?
      answers.each { |ans|
        if ans.answer_status == "correct" then
          correct_ans_found = 1
          break;
        end
      }
    else
      no_options_given = 1
    end

    if no_options_given == 1 then
      error_string = error_string + "No options given"
    end
    if correct_ans_found == 0 then
      error_string = error_string + "No correct answer"
    end
    return error_string
  end

  # It deletes the file and folder for the specified path
  def delete_excel(path_to_delete)
    file_to_del = path_to_delete.split("/").last
    path_to_del = path_to_delete.gsub("/original/"+file_to_del,"")
    FileUtils.rm_r path_to_del
  end

end