require "test/unit"
require "webrick"
require "stringio"
require File.join(File.dirname(__FILE__), "utils.rb")

class WEBrick::TestFileHandler < Test::Unit::TestCase
  def default_file_handler(filename)
    klass = WEBrick::HTTPServlet::DefaultFileHandler
    klass.new(WEBrick::Config::HTTP, filename)
  end

  def windows?
    File.directory?("\\")
  end

  def get_res_body(res)
    return res.body.read rescue res.body
  end

  def make_range_request(range_spec)
    msg = <<-_end_of_request_
      GET / HTTP/1.0
      Range: #{range_spec}

    _end_of_request_
    return StringIO.new(msg.gsub(/^ {6}/, ""))
  end

  def make_range_response(file, range_spec)
    req = WEBrick::HTTPRequest.new(WEBrick::Config::HTTP)
    req.parse(make_range_request(range_spec))
    res = WEBrick::HTTPResponse.new(WEBrick::Config::HTTP)
    size = File.size(file)
    handler = default_file_handler(file)
    handler.make_partial_content(req, res, file, size)
    return res
  end

  def test_make_partial_content
    filename = __FILE__
    filesize = File.size(filename)

    res = make_range_response(filename, "bytes=#{filesize-100}-")
    assert_match(%r{^text/plain}, res["content-type"])
    assert_equal(get_res_body(res).size, 100)

    res = make_range_response(filename, "bytes=-100")
    assert_match(%r{^text/plain}, res["content-type"])
    assert_equal(get_res_body(res).size, 100)

    res = make_range_response(filename, "bytes=0-99")
    assert_match(%r{^text/plain}, res["content-type"])
    assert_equal(get_res_body(res).size, 100)

    res = make_range_response(filename, "bytes=100-199")
    assert_match(%r{^text/plain}, res["content-type"])
    assert_equal(get_res_body(res).size, 100)

    res = make_range_response(filename, "bytes=0-0")
    assert_match(%r{^text/plain}, res["content-type"])
    assert_equal(get_res_body(res).size, 1)

    res = make_range_response(filename, "bytes=-1")
    assert_match(%r{^text/plain}, res["content-type"])
    assert_equal(get_res_body(res).size, 1)

    res = make_range_response(filename, "bytes=0-0, -2")
    assert_match(%r{^multipart/byteranges}, res["content-type"])
  end

  def test_filehandler
    config = { :DocumentRoot => File.dirname(__FILE__), }
    this_file = File.basename(__FILE__)
    TestWEBrick.start_httpserver(config) do |server, addr, port|
      http = Net::HTTP.new(addr, port)
      req = Net::HTTP::Get.new("/")
      http.request(req){|res|
        assert_equal("200", res.code)
        assert_equal("text/html", res.content_type)
        assert_match(/HREF="#{this_file}"/, res.body)
      }
      req = Net::HTTP::Get.new("/#{this_file}")
      http.request(req){|res|
        assert_equal("200", res.code)
        assert_equal("text/plain", res.content_type)
        assert_equal(File.read(__FILE__), res.body)
      }
    end
  end

  def test_non_disclosure_name
    config = { :DocumentRoot => File.dirname(__FILE__), }
    this_file = File.basename(__FILE__)
    TestWEBrick.start_httpserver(config) do |server, addr, port|
      http = Net::HTTP.new(addr, port)
      doc_root_opts = server[:DocumentRootOptions]
      doc_root_opts[:NondisclosureName] = %w(.ht* *~ test_*)
      req = Net::HTTP::Get.new("/")
      http.request(req){|res|
        assert_equal("200", res.code)
        assert_equal("text/html", res.content_type)
        assert_no_match(/HREF="#{File.basename(__FILE__)}"/, res.body)
      }
      req = Net::HTTP::Get.new("/#{this_file}")
      http.request(req){|res|
        assert_equal("404", res.code)
      }
      doc_root_opts[:NondisclosureName] = %w(.ht* *~ TEST_*)
      http.request(req){|res|
        assert_equal("404", res.code)
      }
    end
  end

  def test_directory_traversal
    config = { :DocumentRoot => File.dirname(__FILE__), }
    this_file = File.basename(__FILE__)
    TestWEBrick.start_httpserver(config) do |server, addr, port|
      http = Net::HTTP.new(addr, port)
      req = Net::HTTP::Get.new("/../../")
      http.request(req){|res| assert_equal("400", res.code) }
      req = Net::HTTP::Get.new("/..%5c../#{File.basename(__FILE__)}")
      http.request(req){|res| assert_equal(windows? ? "200" : "404", res.code) }
      req = Net::HTTP::Get.new("/..%5c..%5cruby.c")
      http.request(req){|res| assert_equal("404", res.code) }
    end
  end

  def test_unwise_in_path
    if windows?
      config = { :DocumentRoot => File.dirname(__FILE__), }
      this_file = File.basename(__FILE__)
      TestWEBrick.start_httpserver(config) do |server, addr, port|
        http = Net::HTTP.new(addr, port)
        req = Net::HTTP::Get.new("/..%5c..")
        http.request(req){|res| assert_equal("301", res.code) }
      end
    end
  end

  def test_short_filename
    config = {
      :CGIInterpreter => TestWEBrick::RubyBin,
      :DocumentRoot => File.dirname(__FILE__),
      :CGIPathEnv => ENV['PATH'],
    }
    TestWEBrick.start_httpserver(config) do |server, addr, port|
      http = Net::HTTP.new(addr, port)

      req = Net::HTTP::Get.new("/webric~1.cgi/test")
      http.request(req) do |res|
        if windows?
          assert_equal("200", res.code)
          assert_equal("/test", res.body)
        else
          assert_equal("404", res.code)
        end
      end

      req = Net::HTTP::Get.new("/.htaccess")
      http.request(req) {|res| assert_equal("404", res.code) }
      req = Net::HTTP::Get.new("/htacce~1")
      http.request(req) {|res| assert_equal("404", res.code) }
      req = Net::HTTP::Get.new("/HTACCE~1")
      http.request(req) {|res| assert_equal("404", res.code) }
    end
  end

  def test_script_disclosure
    config = {
      :CGIInterpreter => TestWEBrick::RubyBin,
      :DocumentRoot => File.dirname(__FILE__),
      :CGIPathEnv => ENV['PATH'],
    }
    TestWEBrick.start_httpserver(config) do |server, addr, port|
      http = Net::HTTP.new(addr, port)

      req = Net::HTTP::Get.new("/webrick.cgi/test")
      http.request(req) do |res|
        assert_equal("200", res.code)
        assert_equal("/test", res.body)
      end

      response_assertion = Proc.new do |res|
        if windows?
          assert_equal("200", res.code)
          assert_equal("/test", res.body)
        else
          assert_equal("404", res.code)
        end
      end
      req = Net::HTTP::Get.new("/webrick.cgi%20/test")
      http.request(req, &response_assertion)
      req = Net::HTTP::Get.new("/webrick.cgi./test")
      http.request(req, &response_assertion)
      req = Net::HTTP::Get.new("/webrick.cgi::$DATA/test")
      http.request(req, &response_assertion)
    end
  end
end
