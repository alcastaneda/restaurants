require 'sinatra'
require 'httparty'
enable :sessions

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

def find_restaurants(sanitized_params)
	results = HTTParty.get('https://data.cityofchicago.org/resource/cwig-ma7x.json', 
		{headers: {"X-App-Token": "bjp8KrRvAPtuf809u1UXnI0Z8"},
		query: sanitized_params})
	if results.code == 200 && results.parsed_response != []
		return results
	else
		return "Something went wrong. Check your inputs."
	end
end

get '/' do
	session.clear
	erb :search
end

post '/search' do
	session[:restaurant] = params[:restaurant]
	redirect '/results' 
end

get	'/results' do
	sanitized = sanitize_form(session[:restaurant])
	@results = find_restaurants(sanitized)
	erb :results
end