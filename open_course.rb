require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'twilio-ruby'

availability = 0

puts "Enter the CRN for the PNC course you would like to track:"
crn = gets.chomp.to_s
url = "https://ssb-prod.pnw.edu/dbServer_prod/bwckschd.p_disp_detail_sched?term_in=201710&crn_in=#{crn}"

while availability == 0
    sleep 10
    doc = open(url) { |f| Hpricot(f) }
    
    course_stats = (doc/"table//table//td").collect do |k|
        k.inner_html.split(',')
    end.flatten.compact
    
    availability = course_stats[3].to_i
    
    if availability == 0
        puts "There are no available seats."
        puts "Rechecking in 10 seconds."
        elsif availability == 1
        puts "There is one available seat."
        else
        puts "There are #{availability} seats available."
    end
    
    
    if availability > 0
        account_sid = "000000000000000" #Enter you app sid
        auth_token = "000000000000000" #Enter your Auth token
        client = Twilio::REST::Client.new account_sid, auth_token
        
        #enter app phone number here
        from = "+10000000000"
        
        recipients = {
            #enter recipient phone numbers and names here
            "+100000000000" => "Melanie"
        }
        recipients.each do |key, value|
            client.account.messages.create(
                                           :from => from,
                                           :to => key,
                                           :body => "Hey #{value}, there is space available in that course!"
                                           )
                                           puts "Sent message to #{value}"
        end
    end
end
