require 'sinatra'
require 'httparty'
require 'json'

def sanitize_form(form_params)
	sanitized_params = form_params.each{|k,v| form_params.delete(k) if v.length==0}
	if sanitized_params.key?("Zip")
		sanitized_params["Zip"] = sanitized_params["Zip"].to_i
	end
	if sanitized_params.key?("AKA Name")
		sanitized_params["AKA Name"] = sanitized_params["AKA Name"].upcase
	end
	if sanitized_params.key?("Address")
		sanitized_params["Address"] = sanitized_params["Address"].upcase
	end
	return sanitized_params
end

def format_results(restaurants)
	results= []
	restaurants.each do |restaurant|
		restaurant["inspection_date"]=restaurant["inspection_date"][0..-14]
		if restaurant.key?("violations")
			violations_array = restaurant["violations"].gsub("\n",'').split('|')
			restaurant["violations"]=violations_array.map do |violation|
				violation.downcase.gsub(/[a-z][^.?!]*/){|m| m.capitalize}
			end
		end
		results<<restaurant
	end
	p results
	return results
end

def find_restaurants(sanitized_params)
	request = HTTParty.get('https://data.cityofchicago.org/resource/cwig-ma7x.json', 
		{headers: {"X-App-Token": "bjp8KrRvAPtuf809u1UXnI0Z8"},
		query: sanitized_params})
	if request.code == 200 && request.parsed_response != []
		p request
		results = format_results(request)
		return results
	else
		return "Something went wrong. Check your inputs."
	end
end

get '/' do
	erb :search
end

get	'/results' do
	sanitized = sanitize_form(params[:restaurant])
	@results = find_restaurants(sanitized)
	if request.xhr?
		erb :results, :layout=>false
	else
		erb :results
	end
end