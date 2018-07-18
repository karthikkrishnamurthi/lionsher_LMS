#this is especially written for cutom emails. Its nothing but a parser module which parsers the string and replaces the found patterns with required text
module Mailer

  #loads email content for specific email template
  def load_email_content(email,from_replacements,subject_replacements,body_replacements)
    from = load_from(email.from,from_replacements)
    subject = load_subject(email.subject,subject_replacements)
    body = load_body(email.body,body_replacements)
    return [from,subject,body]
  end

  #loads from content for that email template
  def load_from(email_content,from_replacements)
    total_email_content =  build_email_content(email_content,from_replacements)
    #because 'from' will not accept string with spaces. so remove the spaces
    total_email_content = total_email_content.strip.split(" ").join('')
    return total_email_content
  end

  #loads body content for that email template
  def load_body(email_content,body_replacements)
    total_email_content =  build_email_content(email_content,body_replacements)
    return total_email_content
  end

  #loads subject content for that email template
  def load_subject(email_content,subject_replacements)
    total_email_content =  build_email_content(email_content,subject_replacements)
    return total_email_content
  end

  #take the email content and replacements as arguments.
  #replace the email content with the replacement hash wherever found.
  #eg: Hi [learner_name],<br/><br/>
  # In the above example the below code replaces [learner_name] with value of key [learner_name] in replacements hash
  def build_email_content(email_content,replacements)
    total_email_content = email_content
    replacements.each { |key,value|
    total_email_content = total_email_content.gsub(key,value.to_s)
     }
   return total_email_content
  end
  
end