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

  def test_integration_single_heading
    tempfile = Tempfile.new(['test', '.md'])
    tempfile.write("# Hello World")
    tempfile.close

    stdout, stderr, status = Open3.capture3("ruby", "mdsmith.rb", tempfile.path)

    assert_equal "<h1>Hello World</h1>", stdout.strip
    assert_equal "", stderr
    assert_equal 0, status.exitstatus

    tempfile.unlink
  end

  def test_integration_heading_and_paragraph
    tempfile = Tempfile.new(['test', '.md'])
    tempfile.write("# Title\nThis is a paragraph.")
    tempfile.close

    stdout, stderr, status = Open3.capture3("ruby", "mdsmith.rb", tempfile.path)

    assert_equal "<h1>Title</h1>\n<p>This is a paragraph.</p>", stdout.strip
    assert_equal "", stderr
    assert_equal 0, status.exitstatus

    tempfile.unlink
  end

  def test_integration_multiple_headings
    tempfile = Tempfile.new(['test', '.md'])
    tempfile.write(<<~MD)
      # Main Title
      ## Subtitle
      ### Sub-subtitle
    MD
    tempfile.close

    stdout, stderr, status = Open3.capture3("ruby", "mdsmith.rb", tempfile.path)

    expected = "<h1>Main Title</h1>\n<h2>Subtitle</h2>\n<h3>Sub-subtitle</h3>"
    assert_equal expected, stdout.strip
    assert_equal "", stderr
    assert_equal 0, status.exitstatus

    tempfile.unlink
  end

  def test_integration_mixed_content
    tempfile = Tempfile.new(['test', '.md'])
    tempfile.write(<<~MD)
      # Welcome
      This is the introduction.
      ## Features
      Here are the features.
      ## Installation
      Follow these steps.
    MD
    tempfile.close

    stdout, stderr, status = Open3.capture3("ruby", "mdsmith.rb", tempfile.path)

    expected = "<h1>Welcome</h1>\n<p>This is the introduction.</p>\n<h2>Features</h2>\n<p>Here are the features.</p>\n<h2>Installation</h2>\n<p>Follow these steps.</p>"
    assert_equal expected, stdout.strip
    assert_equal "", stderr
    assert_equal 0, status.exitstatus

    tempfile.unlink
  end

  def test_integration_with_special_chars
    tempfile = Tempfile.new(['test', '.md'])
    tempfile.write("# <Title> & \"Subtitle\"")
    tempfile.close

    stdout, stderr, status = Open3.capture3("ruby", "mdsmith.rb", tempfile.path)

    assert_equal "<h1>&lt;Title&gt; &amp; &quot;Subtitle&quot;</h1>", stdout.strip
    assert_equal "", stderr
    assert_equal 0, status.exitstatus

    tempfile.unlink
  end

  def test_integration_with_blank_lines
    tempfile = Tempfile.new(['test', '.md'])
    tempfile.write(<<~MD)
      # Title

      Paragraph after blank line.

      ## Subtitle
    MD
    tempfile.close

    stdout, stderr, status = Open3.capture3("ruby", "mdsmith.rb", tempfile.path)

    expected = "<h1>Title</h1>\n<p>Paragraph after blank line.</p>\n<h2>Subtitle</h2>"
    assert_equal expected, stdout.strip
    assert_equal "", stderr
    assert_equal 0, status.exitstatus

    tempfile.unlink
  end

  def test_integration_empty_input
    tempfile = Tempfile.new(['test', '.md'])
    tempfile.write("")
    tempfile.close

    stdout, stderr, status = Open3.capture3("ruby", "mdsmith.rb", tempfile.path)

    assert_equal "", stdout.strip
    assert_equal "", stderr
    assert_equal 0, status.exitstatus

    tempfile.unlink
  end
end
