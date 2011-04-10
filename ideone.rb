require 'savon'

class IdeOneClient
  RESULT_CODES = {
    0 => "not running - the paste has been created with run parameter set to false",
    11 => "compilation error - the program could not be executed due to compilation errors",
    12 => "runtime error - the program finished because of the runtime error, for example: division by zero, array index out of bounds, uncaught exception",
    13 => "time limit exceeded - the program didn't stop before the time limit",
    15 => "success - everything went ok",
    17 => "memory limit exceeded - the program tried to use more memory than it is allowed",
    19 => "illegal system call - the program tried to call illegal system function",
    20 => "internal error - some problem occurred on ideone.com; try to submit the paste again and if that fails too, then please contact us"
  }
  RESULT_CODES.default = "unknown result"

  STATUS_CODES = {
    0 => "done",
    1 => "compilation",
    3 => "running"
  }
  STATUS_CODES.default = "unknown status"

  def initialize
    HTTPI.log = false     
    Savon.log = false

    @client = Savon::Client.new do |wsdl|
      wsdl.document = "http://ideone.com/api/1/service.wsdl"
    end

    @auth = { :user => ENV['IDEONE_USER'], :pass => ENV['IDEONE_PASSWORD'] }

    @languages = Hash[request(:get_languages)[:languages][:item].map { |h| [h[:value], h[:key].to_i] }]
  end

  attr_reader :languages

  def map2hash map
    Hash[map.map { |h| [h[:key].to_sym, h[:value]] }]
  end

  def response_map response
    map2hash response.values.first[:return][:item]
  end

  def request method, args = {}
    response = @client.request(method, :body => @auth.merge(args)).to_hash
    map = response_map(response)
    raise "Something bad happened: #{response}" unless map[:error] == "OK"
    map
  end

  def status_text status
    status = status.to_i
    if status < 0
      "waiting for compilation"
    else
      STATUS_CODES[status] 
    end
  end

  def result_text result
    result = result.to_i
    RESULT_CODES[result]
  end

end

client = IdeOneClient.new

source_code = ARGF.read
/language:(?<language_string>.*)$/ =~ source_code

abort "Missing 'language:...' declaration in source" if language_string.nil?

language_found, language_id = client.languages.find { |k,v| k.include?(language_string) }

abort "No match for language '#{language_string}'. Available languages:\n#{client.languages.keys.sort.join("\n")}" if
  language_found.nil?

puts "Submitting with language '#{language_found}'..."

submission_response = client.request :create_submission, 
    :source_code => source_code,
    :language => language_id,
    :input => "",
    :run => true,
    :private => true

submission_id = submission_response[:link]

puts "http://ideone.com/#{submission_id}"

while true do
  submission_details = client.request :get_submission_details,
      :link => submission_id,
      :with_output => true,
      :with_stderr => true,
      :with_cmpinfo => true

  status = submission_details[:status]

  puts client.status_text(status)

  break if status == "0"

  sleep 3
end

puts "Result: #{client.result_text(submission_details[:result])}"
{ :cmpinfo => "Compiler output",
  :output => "Program output",
  :stderr => "Program error output" }.each do |k,t|
  detail = submission_details[k]
  puts "#{t}:\n#{detail}" if detail.kind_of?(String)
end

# Sample submission_details :
#{:error=>"OK"
# :langId=>"1"
# :langName=>"C++"
# :langVersion=>"gcc-4.3.4"
# :time=>"0"
# :date=>"2011-04-10 18:17:08"
# :status=>" 0"
# :result=>"15"
# :memory=>"2724"
# :signal=>"0"
# :public=>false
# :output=>"hello\n"
# :stderr=>{:type=>"xsd:string"}
# :cmpinfo =>{:type=>"xsd:string"}}
#
