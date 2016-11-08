require "csv"
require "sunlight/congress"
require "erb"
require "time"

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zipcode)
  legislators = Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id,form_letter)
  Dir.mkdir("../output") unless Dir.exists? "../output"

  filename = "../output/thanks_#{id}.html"

  File.open(filename,"w") do |file|
    file.puts form_letter
  end
end

def clean_phone_number(phone_number)
  phone_number.gsub!(/[^\d]/, "")
  if phone_number.length == 10
    return phone_number
  elsif phone_number.length == 11 && phone_number[0] == "1"
    phone_number[0] = ""
    return phone_number
  else
    return "Bad Number"
  end
end

def get_reg_hour(reg_date)
  time = reg_date[/\s.+/]
  time[0] = ""
  hour = time[/\d+/]
end

def mode(x)
  sorted = x.sort
  a = Array.new
  b = Array.new
  sorted.each do |x|
    if a.index(x)==nil
      a << x 
      b << 1
    else
      b[a.index(x)] += 1
    end
  end
  maxval = b.max         
  where = b.index(maxval) 
  a[where]                 
end



puts "EventManager initialized"

contents = CSV.open "../event_attendees.csv", headers: true, header_converters: :symbol

template_letter = File.read "../form_letter.erb"
erb_template = ERB.new template_letter

peak_hour = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  reg_hour = get_reg_hour(row[:regdate])
  peak_hour << reg_hour
  zipcode = clean_zipcode(row[:zipcode])
  phone_number = clean_phone_number(row[:homephone])
  legislators = legislators_by_zipcode(zipcode)
  form_letter = erb_template.result(binding)

  save_thank_you_letters(id,form_letter)

end

puts "The best hour to run ads is hour " + mode(peak_hour)
