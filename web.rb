
require 'sinatra'
require 'httpclient'
#http://mysite.com/q3ut4/.



#http://mysite.com/q3ut4/ut4_example.pk3. So when your sv_dlURL is mysite.com, make sure the actual pk3's are in http://mysite.com/q3ut4/.



class MapServer
	attr_accessor :url, :name, :maps
	def initialize(url, maps = [], name = "")
		@url = url
		@maps = maps
		@name = name
	end

	def has_map?(name)
		return @maps.include? name
	end

	def list_map name
		clnt = HTTPClient.new(default_header: {"User-Agent" => "ioq3", "Referer" => 'ioQ3://urbanterror.info'})
		#if clnt.head("#{@url}#{name}", :follow_redirect => true).status == 200
		if clnt.head("#{@url}#{name}").status == 200

			@maps<<name
			return true
		end
		puts  "#{@name} gave status #{clnt.head("#{@url}#{name}")}"
		#puts  "#{@name} gave status #{clnt.head("#{@url}#{name}", :follow_redirect => true)}"

		return false
	end
end


class MapServerManager
	attr_reader :servers
	def initialize(*args)
		@servers = []
	end

	def add_server(server)
		@servers << server
	end

	def find_map name


		# Map already listed
		for s in @servers
			puts "looking for #{name} in #{s.name}"
			return s.url if s.has_map? (name)
		end

		# try to list map
		for s in servers
			puts "querying #{s.name} for #{name}"

			if s.list_map(name)
				puts "found!"
				return s.url
			end

		end

		puts "map not found"
		return nil
	end


	def info
		out = ""
		@servers.each do |s|
			out<<	"<h2> #{s.name} (#{s.url}) </h2>"
			s.maps.each do |m|
				out << "#{m}<br>"
			end
		end

		return out
	end
end

def run manager

	get	'/' do
		manager.info
	end

	get '/map/:map' do

		url1 = manager.find_map(params[:map])

		if url1.nil?
			"map not found on any server"
		else
			puts "rediurectivn"
			newurl = "#{url1}#{params[:map]}"
			puts newurl
			redirect newurl
		end
	end
end

manager = MapServerManager.new
manager.add_server(MapServer.new("http://urbanterror.info/q3ut4/", [""], "urbanterror.info"))
manager.add_server(MapServer.new("http://fallin-angels.org/q3ut4/", ["3story.pk3" ], "fallin angels"))
manager.add_server(MapServer.new("http://ftp.snt.utwente.nl/pub/games/urbanterror/maps/q3ut4/", [""], "utwente"))

#http://ftp.snt.utwente.nl/pub/games/urbanterror/maps/q3ut4/runtfest.pk3




run	manager
