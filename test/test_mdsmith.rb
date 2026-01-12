require "minitest/autorun"
require "tempfile"
require "open3"

class TestMdSmith < Minitest::Test
  def setup
    @tempfile = Tempfile.new('test.md')
    @tempfile.write("# Title\n\nThis is a sample markdown file.\n")
    @tempfile.rewind
  end

  def teardown
    @tempfile.close
    @tempfile.unlink
  end

  def test_markdown_file_exists
    assert File.exist?(@tempfile.path)
    content = @tempfile.read
    assert_includes content, "# Title"
    assert_includes content, "This is a sample markdown file."
  end

  def test_markdown_file_does_not_exist
    nonexistent_file = 'nonexistent.md'
    refute File.exist?(nonexistent_file)

    stdout, stderr, status = Open3.capture3("ruby", "mdsmith.rb", nonexistent_file)

    assert_equal "File not found: #{nonexistent_file}\n", stdout
    assert_equal "", stderr
    assert_equal 1, status.exitstatus
  end

  def test_no_arguments
    stdout, stderr, status = Open3.capture3("ruby", "mdsmith.rb")

    assert_equal "Usage: ruby mdsmith.rb <markdown_file>\n", stdout
    assert_equal "", stderr
    assert_equal 1, status.exitstatus
  end
end
