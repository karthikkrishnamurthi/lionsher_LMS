# Assign the path to your file name first to a local variable.
logopath = "#{Rails.root}/public/images/logo.png"

# Displays the image in your PDF. Dimensions are optional.
pdf.image logopath, :width => 135, :height => 60
pdf.move_down 5
pdf.move_down 50
pdf.font "Helvetica"
pdf.text "Invoice",:style => :bold,:size => 24
pdf.move_down 30
pdf.text "Contact: #{current_user.login} - #{@tenant.organization} "
pdf.move_down 15
pdf.text "InvoiceDate: #{@transaction.created_at.strftime("%d-%m-%Y")}"
pdf.move_down 5
pdf.text "InvoiceNumber: #{@transaction.id}"
pdf.move_down 15
pdf.text "InvoiceFor: Annual Subscription to #{@pricing_plan.no_of_users} users,#{@pricing_plan.space_in_gb} GB Space "
pdf.move_down 15
pdf.text "Price of the plan:  #{(100*@pricing_plan.amount)/(100+13)}"
pdf.move_down 5
pdf.text "Tax(service)13%:  #{@pricing_plan.amount-((100*@pricing_plan.amount)/(100+13))}"
pdf.move_down 5
pdf.text "Total Amount Paid:  #{@pricing_plan.amount}",:style => :bold
pdf.move_down 340
pdf.text "LionSher, A unit of Kern Learning Solutions Pvt. Ltd., Unit-314,Arya Arcade,Vikhroli - West,Mumbai 400083,India",:size => 10