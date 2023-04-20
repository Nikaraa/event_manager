require "csv"
require "google/apis/civicinfo_v2"
require "erb"

def open_cvs
  contents = CSV.open("event_attendees.csv",
                      headers: true,
                      header_converters: :symbol)
end

def legislators_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = "AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw"
  begin
    legislators = civic_info.representative_info_by_address(
      address: zipcode,
      levels: "country",
      roles: ["legislatorUpperBody", "legislatorLowerBody"],
    ).officials
  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

def clean_phone_number(phone_number)
  phone_number.gsub!(/[^\d]/, "")
  if phone_number.length == 10
    phone_number
  elsif phone_number.length == 11 && phone_number[0] == "1"
    phone_number[0..10]
  else
    "Incorrect phone number"
  end
end

def save_thank_you_later(id, letter)
  Dir.mkdir("output") unless Dir.exist?("output")
  filename = "output/thanks_#{id}.html"
  File.open(filename, "w") do |file|
    file.puts letter
  end
end

def common_day
  contents = open_cvs
  day_array = []
  contents.each do |row|
    reg_date = row[:regdate]
    reg_day = Time.strptime(reg_date, "%M/%d/%y %k:%M").strftime("%A")
    day_array.push(reg_day)
  end
  day_hash = day_array.reduce(Hash.new(0)) do |k, v|
    k[v] += 1
    k
  end
  day_hash.max_by { |k, v| v }[0]
end

def common_hour
  contents = open_cvs
  hour_array = []
  contents.each do |row|
    reg_date = row[:regdate]
    reg_hour = Time.strptime(reg_date, "%M/%d/%y %k:%M").strftime("%k")
    hour_array.push(reg_hour)
  end
  hour_hash = hour_array.reduce(Hash.new(0)) do |k, v|
    k[v] += 1
    k
  end
  hour_hash.max_by { |k, v| v }[0]
end

puts "Event Manager Initialized!"
#open_cvs
#
#template_letter = File.read("form_letter.erb")
#erb_template = ERB.new template_letter
#
#contents.each do |row|
# id = row[0]
#name = row[:first_name]
#zipcode = clean_zipcode(row[:zipcode])
#phone_number = clean_phone_number(row[:homephone])
#legislators = legislators_by_zipcode(zipcode)
#form_letter = erb_template.result(binding)
#save_thank_you_later(id, form_letter)
#end
puts "The most common day is: #{common_day}"
puts "The most common hour is: #{common_hour}"
